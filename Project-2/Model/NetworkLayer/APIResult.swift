//
//  APIResult.swift
//  Project-2
//
//  Created by Vsevolod Pavlovskyi on 21.02.2021.
//

import UIKit

// MARK: - APIResult
struct APIResult<T: APIResultContainable>: Codable {
    let items: [T]
    let hasMore: Bool

    enum CodingKeys: String, CodingKey {
        case items
        case hasMore = "has_more"
    }
}

protocol APIResultContainable: Codable {

}

struct SearchResultItem: APIResultContainable {
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

struct QuestionResultItem: APIResultContainable {
    let isAccepted: Bool
    let body: String

    enum CodingKeys: String, CodingKey {
        case isAccepted = "is_accepted"
        case body
    }

    var htmlAttributedBody: NSTextStorage? {
        guard let data = body.data(using: .utf8) else {
            return nil
        }

        return try? NSTextStorage(
            data: data,
            options: [
                .documentType: NSAttributedString.DocumentType.html
            ],
            documentAttributes: nil
        )
    }
}
