//
//  QuestionsViewController.swift
//  Project-2
//
//  Created by Vsevolod Pavlovskyi on 22.02.2021.
//

import UIKit

class QuestionsViewController: UIViewController {

    // MARK: Outlets

    @IBOutlet weak var searchBar: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    // MARK: Variables

    private var dataSource: PrefetchingDataSource<Question, QuestionCell>?

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        prepareCollectionView()
        prepareDataSource()
    }

    // MARK: Actions

    @IBAction func searchButtonTapped(_ sender: Any) {
        guard let text = searchBar.text else {
            return
        }
        search(query: text)
    }
}

// MARK: - Private Methods

private extension QuestionsViewController {

    func search(query: String) {
        activityIndicator.startAnimating()
        dataSource?.query = query
        dataSource?.fetchData(at: IndexPath(row: 0, section: 0))
    }

    func onFetchCompleted(error: Error?) {

        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()

            guard let error = error else {
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
        collectionView.register(UINib(nibName: "QuestionCell", bundle: Bundle.main),
                                forCellWithReuseIdentifier: "CellID")

        // Layout
        let size = NSCollectionLayoutSize(
            widthDimension: NSCollectionLayoutDimension.fractionalWidth(1),
            heightDimension: NSCollectionLayoutDimension.estimated(44)
        )
        let item = NSCollectionLayoutItem(layoutSize: size)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitem: item, count: 1)

        let section = NSCollectionLayoutSection(group: group)

        section.contentInsets = NSDirectionalEdgeInsets(top: 44, leading: 5, bottom: 10, trailing: 5)
        section.interGroupSpacing = 10

        let layout = UICollectionViewCompositionalLayout(section: section)
        collectionView.collectionViewLayout = layout
    }

    func prepareDataSource() {
        dataSource = PrefetchingDataSource<Question, QuestionCell>(
            collectionView: collectionView, completion: onFetchCompleted(error:))
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
}
