//
//  File.swift
//  
//
//  Created by Alexey on 24.03.2023.
//

import Foundation

struct OperatorsResponse: Codable {
    let status: String
    let countryOperators: [String: [String]]?
    let error: String?
}
