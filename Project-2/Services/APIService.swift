//
//  APIService.swift
//  Project-2
//
//  Created by Vsevolod Pavlovskyi on 21.02.2021.
//

import Foundation

public enum Order: String {
    case ascending = "asc"
    case descending = "desc"
}

public enum Sort: String {
    case activity
    case votes
    case creation
    case relevance
}

protocol FetchStrategy {

    var parameters: [String: String] { get set }

    var pathComponent: String { get }

    var additionalParameters: [String: String] { get }
}

struct QuestionsStrategy: FetchStrategy {

    var parameters = [String: String]()

    var pathComponent: String {
        APIConstants.questionsComponent
    }

    var additionalParameters: [String: String] {
        [:]
    }
}

struct AnswersStrategy: FetchStrategy {

    var parameters = [String: String]()

    var pathComponent: String {
        guard let query = parameters["q"] else {
            return ""
        }

        return APIConstants.answersComponent.replacingOccurrences(of: "{ids}", with: query)
    }

    var additionalParameters: [String: String] {
        ["filter": "withbody"]
    }
}

class APIService<T: APIResultContainable> {

    private var fetchStrategy: FetchStrategy

    init(fetchStrategy: FetchStrategy) {
        self.fetchStrategy = fetchStrategy
    }

    lazy private var baseURL = APIConstants.apiBase
    lazy private var networkService = NetworkService(baseURLString: self.baseURL)
    lazy private var apiKey = PrivateConstants.apiKey
    lazy private var site = APIConstants.site

    func fetchPage(
        query: String,
        page: Int,
        pageSize: Int = 15,
        order: Order = .descending,
        sort: Sort = .votes,
        completion: @escaping (Result<APIResult<T>, NetworkError>) -> Void) {

        var parameters: [String: String] = [
            "q": query,
            "order": order.rawValue,
            "sort": sort.rawValue,
            "site": site,
            "page": "\(page)",
            "pageSize": "\(pageSize)",
            "key": apiKey
        ]

        fetchStrategy.parameters = parameters

        let pathComponent = fetchStrategy.pathComponent

        parameters.merge(fetchStrategy.additionalParameters) { (parameters, _) in parameters }

        fetchData(pathComponent: pathComponent,
                  parameters: parameters,
                  completion: completion)
    }

    func fetchData(
        pathComponent: String,
        parameters: [String: String],
        completion: @escaping (Result<APIResult<T>, NetworkError>) -> Void) {

        networkService.getRequest(pathComponent: pathComponent, parameters: parameters) { result in

            switch result {
            case .success(let data):
                data.decode(type: APIResult<T>.self) { result in
                    switch result {
                    case .success(let result):
                        completion(.success(result))
                    case .failure:
                        completion(.failure(.badData))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
