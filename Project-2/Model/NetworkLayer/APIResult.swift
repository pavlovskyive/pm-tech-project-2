//
//  APIResult.swift
//  Project-2
//
//  Created by Vsevolod Pavlovskyi on 21.02.2021.
//

import UIKit

// MARK: - APIResult
struct APIResult<T: APIResultContainable>: Codable {
    var items: [T]
    let hasMore: Bool

    enum CodingKeys: String, CodingKey {
        case items
        case hasMore = "has_more"
    }
}

protocol APIResultContainable: Codable {

}

class Question: APIResultContainable {
    let isAnswered: Bool
    let score: Int
    let questionID: Int
    let title: String

    enum CodingKeys: String, CodingKey {
        case isAnswered = "is_answered"
        case score
        case questionID = "question_id"
        case title
    }
}

struct Owner: Codable {
    var reputation: Int
    var name: String

    enum CodingKeys: String, CodingKey {
        case reputation
        case name = "display_name"
    }
}

class Answer: APIResultContainable {
    let isAccepted: Bool
    var body: String
    var score: Int
    var owner: Owner

    enum CodingKeys: String, CodingKey {
        case isAccepted = "is_accepted"
        case body
        case score
        case owner
    }

    var htmlAttributedBody: NSAttributedString? {
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
