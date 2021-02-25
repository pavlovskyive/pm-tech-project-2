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

    public var headerConfig: AnyObject?

    public var headerReusableClass: ConfigurableSupplementaryView.Type?

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
    private let apiService: APIService<T>?

    private let fetchStrategy: FetchStrategy

    // MARK: Lifecycle

    init(collectionView: UICollectionView,
         fetchStrategy: FetchStrategy,
         completion: @escaping (Error?) -> Void) {

        self.collectionView = collectionView
        self.fetchCompletion = completion
        self.fetchStrategy = fetchStrategy

        apiService = APIService(fetchStrategy: self.fetchStrategy)

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

        apiService?.fetchPage(query: query, page: currentPage) { result in
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

                    let items = apiResult.items

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

        guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CellClass.reuseIdentifier,
                for: indexPath) as? CellClass else {

            fatalError("Could not cast cell")
        }

        let model = models[indexPath.row]
        cell.configure(with: model as AnyObject)

        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath) -> UICollectionReusableView {

        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let headerClass = headerReusableClass else {
                return UICollectionReusableView()
            }

            guard let headerView = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: headerClass.reuseIdentifier,
                    for: indexPath) as? ConfigurableSupplementaryView else {

                return UICollectionReusableView()
            }
            headerView.configure(with: headerConfig)

            return headerView
        default:
            assert(false, "Invalid element type")
        }
    }

    // MARK: UICollectionViewDataSourcePrefetching

    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        guard let last = indexPaths.last else {
            return
        }
        fetchData(at: last)
    }
}
