//
//  ResultsCollectionViewHeader.swift
//  Project-2
//
//  Created by Ilya Senchukov on 25.02.2021.
//

import UIKit

class ResultsCollectionViewHeader: UICollectionReusableView, ConfigurableSupplementaryView {

    @IBOutlet weak var questionTitleLabel: UILabel?
    @IBOutlet weak var questionScoreLabel: UILabel?
    @IBOutlet weak var profileNameLabel: UILabel?
    @IBOutlet weak var profileReputationLabel: UILabel?
    @IBOutlet weak var bodyLabel: UILabel?

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        commonInit()
    }

    override func prepareForReuse() {
        questionTitleLabel?.text = ""
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        bodyLabel?.sizeToFit()
    }
}

private extension ResultsCollectionViewHeader {
    func commonInit() {
        bodyLabel?.numberOfLines = 0
        bodyLabel?.lineBreakMode = .byWordWrapping
    }
}

extension ResultsCollectionViewHeader: Configurable {
    func configure(with model: AnyObject?) {
        guard let model = model as? Question else {
            print("Bad")
            return
        }

        questionTitleLabel?.text = model.title
        questionScoreLabel?.text = "\(model.score)"
        profileNameLabel?.text = model.owner.name
        profileReputationLabel?.text = "\(model.owner.reputation)"

        model.body.attributedStringFromHTML { [weak self] attrString in
            self?.bodyLabel?.attributedText = attrString
        }
    }
}
