//
//  File.swift
//  
//
//  Created by Alexey on 24.03.2023.
//

import Foundation

public struct ActiveActivationsResponse: Codable {
    let status: String
    let activeActivations: [ActiveActivation]?
    let error: String?
}
