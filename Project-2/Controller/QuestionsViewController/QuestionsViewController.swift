//
//  QuestionsViewController.swift
//  Project-2
//
//  Created by Vsevolod Pavlovskyi on 22.02.2021.
//

import UIKit

class QuestionsViewController: UIViewController {
    // MARK: Outlets
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var centerY: NSLayoutConstraint!
    @IBOutlet weak var centerX: NSLayoutConstraint!
    private var isFirstSerch = true
    // MARK: Variables
    let throtllerService: ThrotllerService = ThrotllerService<String>(1)
    private var dataSource: PrefetchingDataSource<QuestionsStrategy, QuestionCell>?

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        throtllerService.add(throttledCallback: search(query:))
        searchBar.delegate = self
        prepareCollectionView()
        prepareDataSource()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        title = "Find your answers"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
    }
}

extension QuestionsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let text = searchBar.text else { return }
        throtllerService.receive(text)
    }
}

// MARK: - UISearchResultsUpdating
extension QuestionsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        throtllerService.receive(text)
    }
}

// MARK: - Private Methods

private extension QuestionsViewController {
    func search(query: String) {
        activityIndicator.startAnimating()
        dataSource?.query = query
        dataSource?.fetchData(at: IndexPath(row: 0, section: 0))
        guard isFirstSerch else { return }
        doSearchBarAnimation()
        isFirstSerch = false
    }

    func doSearchBarAnimation() {
        let safeAreaFrame = self.view.safeAreaLayoutGuide.layoutFrame
        let viewsFrameHeight = self.view.frame.height
        self.centerY.constant = -viewsFrameHeight / 2 + (viewsFrameHeight - safeAreaFrame.height - 40)
        UIView.animate(
            withDuration: 0.4,
            delay: 0,
            options: .curveEaseInOut,
            animations: {
                self.view.layoutIfNeeded()
            })
    }

    func onFetchCompleted(error: Error?) {

        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()

            guard let error = error as? NetworkError,
                  error != .badData else {
                return
            }

            let alertController = UIAlertController(
                title: "Error fetching data",
                message: error.localizedDescription,
                preferredStyle: .alert)

            alertController.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alertController, animated: true)
        }
    }

    // MARK: Preparations

    func prepareCollectionView() {
        collectionView.delegate = self
        let questionCellID = QuestionCell.reuseIdentifier
        collectionView.register(UINib(nibName: questionCellID, bundle: Bundle.main),
                                forCellWithReuseIdentifier: questionCellID)

        // Layout
        let size = NSCollectionLayoutSize(
            widthDimension: NSCollectionLayoutDimension.fractionalWidth(1),
            heightDimension: NSCollectionLayoutDimension.estimated(44)
        )
        let item = NSCollectionLayoutItem(layoutSize: size)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitem: item, count: 1)

        let section = NSCollectionLayoutSection(group: group)

        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 5, bottom: 10, trailing: 5)
        section.interGroupSpacing = 10

        let layout = UICollectionViewCompositionalLayout(section: section)
        collectionView.collectionViewLayout = layout
        collectionView.keyboardDismissMode = .onDrag
    }

    func prepareDataSource() {
        dataSource = PrefetchingDataSource<QuestionsStrategy, QuestionCell>(
            collectionView: collectionView,
            completion: onFetchCompleted(error:))
        collectionView.dataSource = dataSource
        collectionView.prefetchDataSource = dataSource
    }
}

// MARK: - UICollectionViewDelegate

extension QuestionsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.dataSource?.collectionView(collectionView, prefetchItemsAt: [indexPath])
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)

        guard let question = dataSource?.object(with: indexPath) else {
            return
        }

        let resultsVC = ResultsViewController()
        resultsVC.question = question
        navigationController?.pushViewController(resultsVC, animated: true)
    }
}
