//
//  NetworkError.swift
//  Project-2
//
//  Created by Vsevolod Pavlovskyi on 21.02.2021.
//

import Foundation

enum NetworkError: Error, Equatable {
    static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        lhs.localizedDescription == rhs.localizedDescription
    }

    case badURL(String? = nil)
    case URLSession(Error)
    case badResponse
    case badStatusCode(Int)
    case badData
    case badParameter((String, String))
}
