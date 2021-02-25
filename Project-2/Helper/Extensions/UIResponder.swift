//
//  UIResponder.swift
//  Project-2
//
//  Created by Ilya Senchukov on 22.02.2021.
//

import UIKit

extension UIResponder {

    class var reuseIdentifier: String {
        String(describing: self)
    }
}
