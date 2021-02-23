//
//  DetailedViewController.swift
//  Project-2
//
//  Created by Ilya Senchukov on 22.02.2021.
//

import UIKit

class ResultsViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView?

    let apiService = APIService()

    var questionID: Int?
    var page: Int = 1

    var cell = AnswerCollectionViewCell()

    var question: APIResult<QuestionResultItem>? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.collectionView?.reloadData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        prepareCollectionView()
        fetchAnswers()

    }
}

private extension ResultsViewController {

    func prepareCollectionView() {

        collectionView?.dataSource = self
        collectionView?.register(
            UINib(nibName: AnswerCollectionViewCell.reuseIdentifier, bundle: nil),
            forCellWithReuseIdentifier: AnswerCollectionViewCell.reuseIdentifier)
        collectionView?.contentInset.top = 10

        setLayout()
    }

    func setLayout() {
        let size = NSCollectionLayoutSize(
            widthDimension: NSCollectionLayoutDimension.fractionalWidth(1),
            heightDimension: NSCollectionLayoutDimension.estimated(100)
        )

        let item = NSCollectionLayoutItem(layoutSize: size)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitem: item, count: 1)

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        section.interGroupSpacing = 10

        let layout = UICollectionViewCompositionalLayout(section: section)
        collectionView?.collectionViewLayout = layout
    }

    func fetchAnswers() {
        guard let questionID = questionID else {
            return
        }

        apiService.fetchQuestion(questionId: questionID, page: page) { [weak self] res in
            switch res {
            case .failure(let error):
                print(error)
            case .success(let result):
                self?.question = result
            }
        }
    }
}

// MARK: - UICollectionViewDataSource
extension ResultsViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        question?.items.count ?? 0
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: AnswerCollectionViewCell.reuseIdentifier,
                for: indexPath) as? AnswerCollectionViewCell else {
            return UICollectionViewCell()
        }

        let answer = question?.items[indexPath.item]
        cell.body = answer?.htmlAttributedBody

        return cell
    }
}
