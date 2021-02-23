//
//  ThrotllerService.swift
//  Project-2
//
//  Created by Павел Снижко on 23.02.2021.
//

import Foundation

public class ThrotllerService<T> {
    private(set) var value: T?
    private var timeStamp: Date?
    private var interval: TimeInterval
    private var queue: DispatchQueue
    private var callbacks: [(T) -> Void] = []

    public init(_ interval: TimeInterval, on queue: DispatchQueue = .main) {
        self.interval = interval
        self.queue = queue
    }
    public func receive(_ value: T) {
        self.value = value
        guard timeStamp == nil else { return }
        self.timeStamp = Date()
        queue.asyncAfter(deadline: .now() + interval) { [weak self] in
            self?.onDispatch()
        }
    }

    public func add(throttledCallback: @escaping (T) -> Void) {
        self.callbacks.append(throttledCallback)
    }

    private func onDispatch() {
        self.timeStamp = nil
        perfromRequests()
    }

    private func perfromRequests() {
        if let value = self.value { callbacks.forEach { $0(value) } }
    }
}
