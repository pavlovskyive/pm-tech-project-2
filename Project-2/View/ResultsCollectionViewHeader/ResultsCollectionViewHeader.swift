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
    @IBOutlet weak var questionScoreImage: UIImageView?
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
        questionScoreLabel?.text = ""
        profileReputationLabel?.text = ""
        profileNameLabel?.text = ""
        bodyLabel?.text = ""
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
            print("Bad model")
            return
        }

        questionTitleLabel?.text = model.title
        questionScoreLabel?.text = "\(model.score)"
        profileNameLabel?.text = model.owner.name
        profileReputationLabel?.text = "\(model.owner.reputation ?? 0)"
        
        if model.score < 0 {
            questionScoreLabel?.textColor = .systemRed
            questionScoreImage?.tintColor = .systemRed
            questionScoreImage?.image = UIImage(systemName: "hand.thumbsdown")
        } else if model.score > 0 {
            questionScoreLabel?.textColor = .systemGreen
            questionScoreImage?.tintColor = .systemGreen
            questionScoreImage?.image = UIImage(systemName: "hand.thumbsup")
        } else if model.score == 0 {
            questionScoreImage?.image = UIImage(systemName: "circle")
        }

        if abs(model.score) < 3 {
            questionScoreLabel?.textColor = .secondaryLabel
            questionScoreImage?.tintColor = .secondaryLabel
        }

        if let htmlRepresentation = model.htmlRepresentation {
            self.bodyLabel?.attributedText = htmlRepresentation
        } else {
            model.setAttributedString { [weak self] in
                model.htmlRepresentation = $0
                self?.bodyLabel?.attributedText = $0
            }
        }
    }
}
