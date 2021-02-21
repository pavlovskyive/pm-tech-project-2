//
//  APIService.swift
//  Project-2
//
//  Created by Vsevolod Pavlovskyi on 21.02.2021.
//

import Foundation

class APIService {

    lazy private var baseURL = APIConstants.apiBase
    lazy private var networkService = NetworkService(baseURLString: self.baseURL)

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

    public func search(query: String,
                       page: Int,
                       pageSize: Int = 15,
                       order: Order = .descending,
                       sort: Sort = .votes,
                       completion: @escaping (Result<APIResult<SearchResultItem>, NetworkError>) -> Void) {

        guard page > 0 && page < 128 else {
            completion(.failure(.badParameter(("page", "\(page)"))))
            return
        }

        guard pageSize > 0 && pageSize < 128 else {
            completion(.failure(.badParameter(("pageSize", "\(pageSize)"))))
            return
        }

        let site = APIConstants.site
        let searchComponent = APIConstants.searchComponent

        let parameters: [String: String] = [
            "q": query,
            "order": order.rawValue,
            "sort": sort.rawValue,
            "site": site,
            "page": "\(page)",
            "pageSize": "\(pageSize)"
        ]

        networkService.getRequest(pathComponent: searchComponent, parameters: parameters) { result in

            switch result {
            case .success(let data):
                data.decode(type: APIResult<SearchResultItem>.self) { result in
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

    public func fetchQuestion(questionId: Int,
                              page: Int,
                              pageSize: Int = 30,
                              order: Order = .descending,
                              sort: Sort = .votes,
                              completion: @escaping (Result<APIResult<QuestionResultItem>, NetworkError>) -> Void) {

        guard page > 0 && page < 128 else {
            completion(.failure(.badParameter(("page", "\(page)"))))
            return
        }

        guard pageSize > 0 && pageSize < 128 else {
            completion(.failure(.badParameter(("pageSize", "\(pageSize)"))))
            return
        }

        let site = APIConstants.site
        let pathComponent = APIConstants
            .questionComponent.replacingOccurrences(of: "{ids}", with: "\(questionId)")

        let parameters: [String: String] = [
            "order": order.rawValue,
            "sort": sort.rawValue,
            "site": site,
            "filter": "withbody",
            "page": "\(page)",
            "pageSize": "\(pageSize)"
        ]

        networkService.getRequest(pathComponent: pathComponent, parameters: parameters) { result in

            switch result {
            case .success(let data):
                data.decode(type: APIResult<QuestionResultItem>.self) { result in
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
