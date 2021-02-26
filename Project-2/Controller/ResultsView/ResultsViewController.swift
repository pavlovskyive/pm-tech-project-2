//
//  DetailedViewController.swift
//  Project-2
//
//  Created by Ilya Senchukov on 22.02.2021.
//

import UIKit

class ResultsViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView?
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView?

    private var dataSource: PrefetchingDataSource<AnswersStrategy, AnswerCollectionViewCell>?

    var question: Question?

    override func viewDidLoad() {
        super.viewDidLoad()

        prepareCollectionView()
        prepareDataSource()
        fetchAnswers()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationItem.title = ""
        navigationItem.largeTitleDisplayMode = .never
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        collectionView?.collectionViewLayout.invalidateLayout()
    }
}

// MARK: - Network
private extension ResultsViewController {

    func fetchAnswers() {
        guard let question = question else { return }

        activityIndicator?.startAnimating()
        dataSource?.query = "\(question.questionID)"
        dataSource?.fetchData(at: IndexPath(item: 0, section: 0))
    }

    func onFetchCompleted(error: Error?) {

        UIView.animate(withDuration: 1) { [weak self] in
            self?.collectionView?.alpha = 1
        }

        DispatchQueue.main.async { [weak self] in

            guard let self = self, let activityIndicator = self.activityIndicator else {
                return
            }

            activityIndicator.stopAnimating()

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
}

// MARK: - Preparations
private extension ResultsViewController {

    func prepareDataSource() {
        guard let collectionView = collectionView else {
            return
        }

        dataSource = PrefetchingDataSource<AnswersStrategy, AnswerCollectionViewCell>(
            collectionView: collectionView,
            completion: onFetchCompleted(error:))
        dataSource?.headerConfig = question
        dataSource?.headerReusableClass = ResultsCollectionViewHeader.self

        collectionView.dataSource = dataSource
        collectionView.delegate = self
        collectionView.prefetchDataSource = dataSource

        dataSource?.fetchData(at: IndexPath(row: 0, section: 0))
    }

    func prepareCollectionView() {

        collectionView?.alpha = 0

        collectionView?.register(
            UINib(nibName: AnswerCollectionViewCell.reuseIdentifier, bundle: nil),
            forCellWithReuseIdentifier: AnswerCollectionViewCell.reuseIdentifier)
        collectionView?.register(
            UINib(nibName: ResultsCollectionViewHeader.reuseIdentifier, bundle: nil),
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: ResultsCollectionViewHeader.reuseIdentifier)

        collectionView?.contentInset.top = 10

        setLayout()
    }

    func setLayout() {
        let size = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(250)
        )

        let item = NSCollectionLayoutItem(layoutSize: size)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitem: item, count: 1)

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        section.interGroupSpacing = 20

        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(200)
        )

        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )

        section.boundarySupplementaryItems = [header]
        let layout = UICollectionViewCompositionalLayout(section: section)

        collectionView?.collectionViewLayout = layout
    }
}

extension ResultsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.dataSource?.collectionView(collectionView, prefetchItemsAt: [indexPath])
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let model = self.dataSource?.object(with: indexPath)

        let detailedVC = DetailedAnswerViewController(nibName: "DetailedAnswerViewController", bundle: Bundle.main)
        detailedVC.model = model

        navigationController?.pushViewController(detailedVC, animated: true)
    }
}
