//
//  APIResult.swift
//  Project-2
//
//  Created by Vsevolod Pavlovskyi on 21.02.2021.
//

import Foundation

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

class Answer: APIResultContainable {
    let isAccepted: Bool
    let body: String

    enum CodingKeys: String, CodingKey {
        case isAccepted = "is_accepted"
        case body
    }
}
