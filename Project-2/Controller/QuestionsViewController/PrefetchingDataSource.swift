//
//  PrefetchingDataSource.swift
//  Project-2
//
//  Created by Vsevolod Pavlovskyi on 23.02.2021.
//

import UIKit

// swiftlint:disable line_length
class PrefetchingDataSource<T: APIResultContainable, CellClass: UICollectionViewCell>: NSObject, UICollectionViewDataSource, UICollectionViewDataSourcePrefetching where CellClass: Configurable {
    // swiftlint:enable line_length

    // MARK: Public Variables

    // Search query
    public var query: String? {
        didSet {
            resetData()
        }
    }

    // MARK: Private Properties

    // Fetching margin (meaning we fetch data for 20 cells in advance for smooth scrolling)
    private var margin = 20

    // Model
    private var models = [T]()

    // CollectionView Link
    private weak var collectionView: UICollectionView?

    // Do when fetching ended
    private var fetchCompletion: (Error?) -> Void

    // There are more data with this query
    private var hasMore = true

    // Is data source currently fetching
    private var isFetching = false

    // Current page
    private var currentPage = 0

    // Size of one page
    private var pageSize = 15

    // Api service
    private let apiService = APIService<Question>()

    // MARK: Lifecycle

    init(collectionView: UICollectionView,
         completion: @escaping (Error?) -> Void) {

        self.collectionView = collectionView
        self.fetchCompletion = completion

        super.init()
    }

    // MARK: Public Methods

    public func fetchData(at indexPath: IndexPath) {

        let index = indexPath.row + margin

        guard !isFetching,
              hasMore,
              index / pageSize >= currentPage,
              let query = query,
              !query.isEmpty else {
            self.fetchCompletion(nil)
            return
        }

        currentPage += 1

        isFetching = true

        apiService.fetchPage(query: query, page: pageSize) { result in
            switch result {
            case .success(let apiResult):
                DispatchQueue.main.async {
                    self.isFetching = false

                    self.hasMore = apiResult.hasMore

                    var paths = [IndexPath]()
                    for item in 0..<apiResult.items.count {
                        let indexPath = IndexPath(row: item + self.models.count, section: 0)
                        paths.append(indexPath)
                    }

                    guard let items = apiResult.items as? [T] else {
                        self.fetchCompletion(NetworkError.badData)
                        return
                    }

                    self.models.append(contentsOf: items)
                    self.collectionView?.insertItems(at: paths)
                }
            case .failure(let error):
                self.fetchCompletion(error)
                self.isFetching = false
                print(error)
            }
        }
    }

    public func object(with indexPath: IndexPath) -> T? {
        guard models.count > indexPath.row else {
            return nil
        }

        return models[indexPath.row]
    }

    // MARK: Private Methods

    private func resetData() {
        var paths = [IndexPath]()
        for item in 0..<models.count {
            let indexPath = IndexPath(row: item, section: 0)
            paths.append(indexPath)
        }
        models = []
        collectionView?.deleteItems(at: paths)

        hasMore = true

        currentPage = 0
    }

    // MARK: UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return models.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView
                .dequeueReusableCell(withReuseIdentifier: "CellID", for: indexPath) as? CellClass else {
            fatalError("Could not cast cell")
        }

        let model = models[indexPath.row]
        cell.configure(with: model as AnyObject)

        return cell
    }

    // MARK: UICollectionViewDataSourcePrefetching

    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        guard let last = indexPaths.last else {
            return
        }
        fetchData(at: last)
    }
}

extension PrefetchingDataSource {

    func getModel(at index: IndexPath) -> T? {
        return models[index.item]
    }
}
