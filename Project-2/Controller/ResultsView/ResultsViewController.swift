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

    var question: APIResult<QuestionResultItem>? {
        didSet {
            DispatchQueue.main.sync {
                collectionView?.reloadData()
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
        collectionView?.delegate = self
        collectionView?.register(
            UINib(nibName: AnswerCollectionViewCell.reuseIdentifier, bundle: nil),
            forCellWithReuseIdentifier: AnswerCollectionViewCell.reuseIdentifier)
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

// MARK: - UICollectionViewDelegateFlowLayout
extension ResultsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath) -> CGSize {

        CGSize(width: collectionView.bounds.width, height: 200)
    }
}
