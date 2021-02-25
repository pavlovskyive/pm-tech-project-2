//
//  AnswerCollectionViewCell.swift
//  Project-2
//
//  Created by Ilya Senchukov on 22.02.2021.
//

import UIKit

class AnswerCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var bodyLabel: UILabel?
    @IBOutlet weak var answerScoreLabel: UILabel?
    @IBOutlet weak var profileNameLabel: UILabel?
    @IBOutlet weak var profileReputationLabel: UILabel?
    @IBOutlet weak var scoreImage: UIImageView!

    override init(frame: CGRect) {
        super.init(frame: frame)

        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        commonInit()
    }
}

private extension AnswerCollectionViewCell {
    func commonInit() {
        prepareBodyLabel()
    }

    func prepareBodyLabel() {
        bodyLabel?.numberOfLines = 0
        bodyLabel?.lineBreakMode = .byWordWrapping
    }
}

extension AnswerCollectionViewCell: Configurable {
    func configure(with model: AnyObject?) {
        guard let model = model as? Answer else {
            return
        }

        answerScoreLabel?.text = "\(model.score)"
        profileNameLabel?.text = model.owner.name
        profileReputationLabel?.text = "\(model.owner.reputation ?? 0)"

        model.setAttributedString { [weak self] in
            self?.bodyLabel?.attributedText = $0
        }

        if model.score < 0 {
            answerScoreLabel?.textColor = .systemRed
            scoreImage.tintColor = .systemRed
            scoreImage.image = UIImage(systemName: "hand.thumbsdown")
        } else if model.score > 0 {
            answerScoreLabel?.textColor = .systemGreen
            scoreImage.tintColor = .systemGreen
            scoreImage.image = UIImage(systemName: "hand.thumbsup")
        } else if model.score == 0 {
            scoreImage.image = UIImage(systemName: "circle")
        }

        if abs(model.score) < 3 {
            answerScoreLabel?.textColor = .secondaryLabel
            scoreImage.tintColor = .secondaryLabel
        }
    }
}
