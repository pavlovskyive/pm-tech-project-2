//
//  BodyContainable.swift
//  Project-2
//
//  Created by Ilya Senchukov on 25.02.2021.
//

import Foundation

protocol BodyContaining {
    var body: String { get set }

    var htmlAttributedString: NSAttributedString? { get }
}

extension BodyContaining {
    var htmlAttributedString: NSAttributedString? {
        let body = """
        <!doctype html>
        <html>
            <style>
                p {
                    font-family: '-apple-system', 'HelveticaNeue';
                    font-size: 14
                }
                code {
                    background-color: #f2f2f2;
                }
            </style>
            <body>
                \(self.body)
            </body>
        </html>
        """

        guard let data = body.data(using: .utf8) else {
            return nil
        }

        return try? NSAttributedString(
            data: data,
            options: [
                .documentType: NSAttributedString.DocumentType.html
            ],
            documentAttributes: nil)
    }
}
