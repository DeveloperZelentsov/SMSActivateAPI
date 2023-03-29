//
//  File.swift
//  
//
//  Created by Alexey on 24.03.2023.
//

import Foundation

public enum SmsActivateError: String, LocalizedError, CaseIterable {
    case badAction = "BAD_ACTION"
    case badService = "BAD_SERVICE"
    case badKey = "BAD_KEY"
    case errorSql = "ERROR_SQL"
    case banned = "BANNED"
    case wrongExceptionPhone = "WRONG_EXCEPTION_PHONE"
    case noBalanceForward = "NO_BALANCE_FORWARD"
    case noActivation = "NO_ACTIVATION"
    case badStatus = "BAD_STATUS"
    case noActivations = "NO_ACTIVATIONS"
    case operatorsNotFound = "OPERATORS_NOT_FOUND"
    case badAnswer = "badAnswer"
    case noCodeReceived = "noCodeReceived"
    case activationCancelled = "activationCancelled"
    
    
    public var errorDescription: String? {
        switch self {
        case .badAction:
            return "Incorrect action"
        case .badService:
            return "Incorrect service name"
        case .badKey:
            return "Invalid API key"
        case .errorSql:
            return "SQL server error"
        case .banned:
            return "Account is banned"
        case .wrongExceptionPhone:
            return "Incorrect excluding prefixes"
        case .noBalanceForward:
            return "Insufficient funds for purchasing forwarding"
        case .noActivation:
            return "Activation ID does not exist"
        case .badStatus:
            return "Incorrect status"
        case .noActivations:
            return "No active activations found"
        case .operatorsNotFound:
            return "Operators not found"
        case .badAnswer:
            return "Incorrect answer"
        case .noCodeReceived:
            return "No code was received after the specified number of attempts."
        case .activationCancelled:
            return "The activation was cancelled."
        }
    }
}
