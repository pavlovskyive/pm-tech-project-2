//
//  TextAttachmentProcessor.swift
//  Project-2
//
//  Created by Ilya Senchukov on 24.02.2021.
//

import Foundation

protocol TextAttachmentPreloader {
    func preloadAttachments(attrString: NSMutableAttributedString) -> NSMutableAttributedString
}
