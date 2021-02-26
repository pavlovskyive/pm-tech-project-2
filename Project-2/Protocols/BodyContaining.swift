//
//  BodyContainable.swift
//  Project-2
//
//  Created by Ilya Senchukov on 25.02.2021.
//

import UIKit

protocol BodyContaining: class {
    var body: String { get set }
    var htmlRepresentation: NSAttributedString? { get set }
}

extension BodyContaining {
    func setAttributedString(completion: @escaping (NSAttributedString?) -> Void) {
        let body = """
        <!doctype html>
        <html>
            <style>
                html {
                    font-family: '-apple-system', BlinkMacSystemFont, sans-serif;
                    line-height: 1.5;
                }
                p {
                    font-size: 1.2rem;
                    margin-bottom: 0.5rem;
                }
                ul {
                    margin-bottom: 2rem;
                }
                li {
                    font-size: 1.2rem;
                    margin-bottom: 0.2rem;
                }
                code {
                    font-weight: normal;
                    line-height: 1.5;
                }
                img {
                    max-height: 100%;
                    max-width: \(UIScreen.main.bounds.width - 40) !important;
                }
            </style>
            <body>
                \(self.body)
            </body>
        </html>
        """

        body.attributedStringFromHTML { string in
            completion(string)
        }
    }
}
