//
//  DetailedAnswerViewController.swift
//  Project-2
//
//  Created by Vsevolod Pavlovskyi on 25.02.2021.
//

import UIKit

class DetailedAnswerViewController: UIViewController {

    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var ownerLabel: UILabel!

    var model: Answer?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
    }
}

private extension DetailedAnswerViewController {
    func setupViews() {
        guard let model = model else {
            return
        }

        ownerLabel.text = model.owner.name
        model.setAttributedString { [weak self] in
            self?.bodyLabel.attributedText = $0
        }
    }
}
