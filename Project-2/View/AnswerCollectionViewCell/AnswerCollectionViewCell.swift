//
//  AnswerCollectionViewCell.swift
//  Project-2
//
//  Created by Ilya Senchukov on 22.02.2021.
//

import UIKit

class AnswerCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var bodyLabel: UILabel?

    var body: NSAttributedString? {
        didSet {
            bodyLabel?.attributedText = body
        }
    }
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
