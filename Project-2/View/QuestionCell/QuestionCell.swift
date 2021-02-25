//
//  QuestionCell.swift
//  Project-2
//
//  Created by Vsevolod Pavlovskyi on 22.02.2021.
//

import UIKit

class QuestionCell: UICollectionViewCell, Configurable {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var isAnsweredImageView: UIImageView!
    @IBOutlet weak var answeredLabel: UILabel!

    private var widthConstraint: NSLayoutConstraint?

    override func prepareForReuse() {
        super.prepareForReuse()

        configure(with: nil)
    }

    func configure(with model: AnyObject?) {
        guard let question = model as? Question else {
            title.text = ""
            title.alpha = 0
            answeredLabel.alpha = 0
            isAnsweredImageView.alpha = 0

            return
        }

        title?.text = question.title
        title.alpha = 1
        answeredLabel.alpha = 1
        isAnsweredImageView.alpha = 1

        let imageSystemName: String
        let imageColor: UIColor

        if question.isAnswered {
            imageSystemName = "checkmark.circle"
            imageColor = UIColor.systemGreen
        } else {
            imageSystemName = "multiply.circle"
            imageColor = UIColor.systemRed
        }

        isAnsweredImageView.image = UIImage(systemName: imageSystemName)
        isAnsweredImageView.tintColor = imageColor
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
