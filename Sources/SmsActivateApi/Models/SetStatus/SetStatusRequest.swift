//
//  File.swift
//  
//
//  Created by Alexey on 24.03.2023.
//

import Foundation

public struct SetStatusRequest: Codable {
    
    let id: Int
    let status: ActivationStatus
    var forward: String?

    public enum ActivationStatus: Int, Codable {
        case ready = 1
        case requestAnotherCode = 3
        case completeActivation = 6
        case cancelActivation = 8
    }
    
    public init(id: Int, status: ActivationStatus, forward: String? = nil) {
        self.id = id
        self.status = status
        self.forward = forward
    }
}
