//
//  String.swift
//  Project-2
//
//  Created by Ilya Senchukov on 25.02.2021.
//

import UIKit

extension String {
    func attributedStringFromHTML(completionBlock: @escaping (NSAttributedString?) -> Void) {
        guard let data = data(using: .utf8) else {
            print("Unable to decode data from html string: \(self)")
            return completionBlock(nil)
        }

        let options = [
            NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html,
            NSAttributedString.DocumentReadingOptionKey.characterEncoding:
                NSNumber(value: String.Encoding.utf8.rawValue)
        ] as [NSAttributedString.DocumentReadingOptionKey: Any]

        DispatchQueue.main.async {
            if let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) {
                completionBlock(attributedString)
            } else {
                print("Unable to create attributed string from html string: \(self)")
                completionBlock(nil)
            }
        }

    }
}
