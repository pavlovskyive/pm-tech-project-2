//
//  ViewController.swift
//  Project-2
//
//  Created by Vsevolod Pavlovskyi on 19.02.2021.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func presentResults() {
        let resultsView = ResultsViewController()

        resultsView.questionID = 39430231

        navigationController?.pushViewController(resultsView, animated: true)
    }
}
