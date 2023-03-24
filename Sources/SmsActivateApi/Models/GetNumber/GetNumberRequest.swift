//
//  File.swift
//  
//
//  Created by Alexey on 24.03.2023.
//

import Foundation

public struct GetNumberRequest: Codable {

    let service: Service
    let forward: Bool?
    let `operator`: String?
    let ref: String
    let country: String?
    let phoneException: String?
    let freePrice: Bool?
    let maxPrice: String?
    let verification: Bool?
    
    public init(service: Service, forward: Bool? = nil, `operator`: String? = nil, ref: String = "921566", country: String? = nil, phoneException: String? = nil, freePrice: Bool? = nil, maxPrice: String? = nil, verification: Bool? = nil) {
        self.service = service
        self.forward = forward
        self.`operator` = `operator`
        self.ref = ref
        self.country = country
        self.phoneException = phoneException
        self.freePrice = freePrice
        self.maxPrice = maxPrice
        self.verification = verification
    }
}
