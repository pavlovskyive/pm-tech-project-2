//
//  NetworkService.swift
//  Project-2
//
//  Created by Vsevolod Pavlovskyi on 21.02.2021.
//

import Foundation

class NetworkService {

    private var baseURLString: String

    init(baseURLString: String) {
        self.baseURLString = baseURLString
    }

    public func getRequest(
        pathComponent: String,
        parameters: [String: String]? = nil,
        completion: @escaping (Result<Data, NetworkError>) -> Void) {

        var urlComponents = URLComponents(string: baseURLString)

        urlComponents?.path = pathComponent

        if let parameters = parameters {
            var queryItems = [URLQueryItem]()
            parameters.forEach {
                let queryItem = URLQueryItem(name: $0.key, value: $0.value)
                queryItems.append(queryItem)
            }

            urlComponents?.queryItems = queryItems
        }

        guard let url = urlComponents?.url else {
            completion(.failure(.badURL(urlComponents?.string)))
            return
        }

        let request = URLRequest(url: url)

        createDataTask(with: request, completion: completion)
    }
}

private extension NetworkService {
    func createDataTask(with request: URLRequest,
                        completion: @escaping (Result<Data, NetworkError>) -> Void) {

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(.failure(.URLSession(error)))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.badResponse))
                return
            }

            let statusCode = httpResponse.statusCode

            guard (200..<300).contains(statusCode) else {
                completion(.failure(.badStatusCode(statusCode)))
                return
            }

            guard let data = data else {
                completion(.failure(.badData))
                return
            }

            completion(.success(data))
        }

        task.resume()
    }
}
