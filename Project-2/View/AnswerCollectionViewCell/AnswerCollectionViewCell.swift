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

        model.body.attributedStringFromHTML { [weak self] attrString in
            self?.bodyLabel?.attributedText = attrString
        }

        answerScoreLabel?.text = "\(model.score)"
        profileNameLabel?.text = model.owner.name
        profileReputationLabel?.text = "\(model.owner.reputation)"
    }
}
