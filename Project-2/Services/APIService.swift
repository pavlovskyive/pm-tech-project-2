//
//  APIService.swift
//  Project-2
//
//  Created by Vsevolod Pavlovskyi on 21.02.2021.
//

import Foundation

class APIService <T: APIResultContainable> {

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

    lazy private var baseURL = APIConstants.apiBase
    lazy private var networkService = NetworkService(baseURLString: self.baseURL)
    lazy private var apiKey = PrivateConstants.apiKey
    lazy private var site = APIConstants.site

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

extension APIService where T == Question {

    func fetchPage(
        query: String,
        page: Int,
        pageSize: Int = 15,
        order: Order = .descending,
        sort: Sort = .votes,
        completion: @escaping (Result<APIResult<T>, NetworkError>) -> Void) {

        let parameters: [String: String] = [
            "q": query,
            "order": order.rawValue,
            "sort": sort.rawValue,
            "site": site,
            "page": "\(page)",
            "pageSize": "\(pageSize)",
            "key": apiKey
        ]

        let pathComponent = APIConstants.questionsComponent

        fetchData(pathComponent: pathComponent,
                  parameters: parameters,
                  completion: completion)
    }
}

extension APIService where T == Answer {

    func fetchPage(
        query: String,
        page: Int,
        pageSize: Int = 15,
        order: Order = .descending,
        sort: Sort = .votes,
        completion: @escaping (Result<APIResult<T>, NetworkError>) -> Void) {

        let parameters: [String: String] = [
            "order": order.rawValue,
            "sort": sort.rawValue,
            "site": site,
            "page": "\(page)",
            "pageSize": "\(pageSize)",
            "filter": "withbody",
            "key": apiKey
        ]

        let pathComponent = APIConstants
            .answersComponent.replacingOccurrences(of: "{ids}", with: query)

        fetchData(pathComponent: pathComponent,
                  parameters: parameters,
                  completion: completion)
    }
}
