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

class Question: APIResultContainable, BodyContaining {
    let isAnswered: Bool
    let score: Int
    let questionID: Int
    let title: String
    let owner: Owner
    var body: String

    enum CodingKeys: String, CodingKey {
        case isAnswered = "is_answered"
        case score
        case questionID = "question_id"
        case title
        case owner
        case body
    }
}

class Answer: APIResultContainable, BodyContaining {
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
}
