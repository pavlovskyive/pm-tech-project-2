//
//  Owner.swift
//  Project-2
//
//  Created by Ilya Senchukov on 25.02.2021.
//

import Foundation

struct Owner: Codable {
    var reputation: Int?
    var name: String

    enum CodingKeys: String, CodingKey {
        case reputation
        case name = "display_name"
    }
}
