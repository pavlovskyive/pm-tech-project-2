//
//  APIService.swift
//  Project-2
//
//  Created by Vsevolod Pavlovskyi on 21.02.2021.
//

import Foundation

typealias FetchPageParameters<T: APIResultContainable> = (
    query: String,
    page: Int,
    pageSize: Int,
    order: Order,
    sort: Sort,
    completion: (Result<APIResult<T>, NetworkError>) -> Void)

typealias FetchDataParameters<T: APIResultContainable> = (
    pathComponent: String,
    fetchPageParameters: FetchPageParameters<T>)

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

    associatedtype Model: APIResultContainable

    init()

    func adaptFetch(fetchPageParameters: FetchPageParameters<Model>) -> FetchDataParameters<Model>
}

struct QuestionsStrategy: FetchStrategy {

    typealias Model = Question

    init() {}

    func adaptFetch(fetchPageParameters: FetchPageParameters<Model>) -> FetchDataParameters<Model> {
        let pathComponent = APIConstants.questionsComponent

        return (pathComponent: pathComponent,
                fetchPageParameters: fetchPageParameters)
    }
}

struct AnswersStrategy: FetchStrategy {

    typealias Model = Answer

    init() {}

    func adaptFetch(fetchPageParameters: FetchPageParameters<Model>) -> FetchDataParameters<Model> {
        let query = fetchPageParameters.query

        let pathComponent = APIConstants.answersComponent.replacingOccurrences(of: "{ids}", with: query)

        return (pathComponent: pathComponent,
                fetchPageParameters: fetchPageParameters)
    }
}

class APIService<T: FetchStrategy> {

    typealias Model = T.Model

    private var fetchStrategy = T()

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
        completion: @escaping (Result<APIResult<Model>, NetworkError>) -> Void) {

        let parameters: [String: String] = [
            "q": query,
            "order": order.rawValue,
            "sort": sort.rawValue,
            "site": site,
            "page": "\(page)",
            "pageSize": "\(pageSize)",
            "filter": "withbody",
            "key": apiKey
        ]

        let fetchPageParameters: FetchPageParameters<Model> = (
            query: query,
            page: page,
            pageSize: pageSize,
            order: order,
            sort: sort,
            completion: completion)

        let fetchDataParameters = fetchStrategy.adaptFetch(fetchPageParameters: fetchPageParameters)

        fetchData(pathComponent: fetchDataParameters.pathComponent,
                  parameters: parameters,
                  completion: completion)
    }

    func fetchData(
        pathComponent: String,
        parameters: [String: String],
        completion: @escaping (Result<APIResult<Model>, NetworkError>) -> Void) {

        networkService.getRequest(pathComponent: pathComponent, parameters: parameters) { result in

            switch result {
            case .success(let data):
                data.decode(type: APIResult<T.Model>.self) { result in
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
