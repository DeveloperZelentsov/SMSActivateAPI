//
//  File.swift
//  
//
//  Created by Alexey on 24.03.2023.
//

import Foundation

public struct ActiveActivation: Codable, Equatable {
    public let activationId: String
    public let serviceCode: String
    public let phoneNumber: String
    public let activationCost: String
    public let activationStatus: String
    public let smsCode: String?
    public let smsText: String?
    public let activationTime: String
    public let discount: String
    public let repeated: String
    public let countryCode: String
    public let countryName: String
    public let canGetAnotherSms: String
}

