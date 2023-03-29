//
//  File.swift
//  
//
//  Created by Alexey on 24.03.2023.
//

import Foundation

public protocol ISmsActivateAPI: AnyObject {
    /// Retrieves the account balance or balance including cashback.
    /// - Parameter state: An enum value representing whether to get only the balance or balance with cashback.
    /// - Returns: A String representing the account balance or balance including cashback.
    func getBalance(with state: BalanceState) async throws -> String
    
    /// Requests a phone number.
    /// - Parameter request: A GetActivateNumberRequest object containing the phone number request information.
    /// - Returns: A tuple with two Int values, the first representing the activation ID, and the second representing the phone number.
    func getNumber(request: GetActivateNumberRequest) async throws -> (Int, Int)
    
    /// Gets available operators for a given country.
    /// - Parameter countryId: The country code for which the operators are to be retrieved.
    /// - Returns: A dictionary with country codes as keys and arrays of operator names as values.
    func getOperators(countryId: Int) async throws -> [String]
    
    /// Retrieves the list of all countries.
    /// - Returns: An array of CountryResponse objects representing the countries.
    func getCountries() async throws -> [CountryResponse]
    
    /// Retrieves the activation status.
    /// - Parameter id: The activation ID.
    /// - Returns: A tuple with an ActivationStatus enum value representing the status and an optional
    func getStatus(id: Int) async throws -> (GetStatus, String?)
    
    /// Retrieves active activations.
    /// - Returns: An array of ActiveActivation objects representing the active activations.
    func getActiveActivations() async throws -> [ActiveActivation]
    
    /// Sets the activation status.
    /// - Parameter request: A SetActivationStatusRequest object containing the activation status update information.
    /// - Returns: A SetActivationStatusResponse object representing the response from the SMS Activate API.
    func setStatus(request: SetActivationStatusRequest) async throws -> SetActivationStatusResponse
    
    /// Waits for a code to be received from the server.
    /// - Parameters:
    ///   - id: The activation ID.
    ///   - attempts: The number of attempts to wait for the SMS code from the server. Default value is 40. (About 2 minutes)
    ///   - setStatusAfterCompletion: A boolean indicating whether to set the status after receiving the code or not. Default value is false.
    /// - Returns: The received code as a string.
    /// - Throws: An error if the code was not received after the specified number of attempts or if the activation was cancelled.
    func waitForCode(id: Int, attempts: Int, setStatusAfterCompletion: Bool) async throws -> String
}

public final class SmsActivateAPI: HTTPClient, ISmsActivateAPI {

    let urlSession: URLSession
    
    public init(apiKey: String,
                baseScheme: String = Constants.baseScheme,
                baseHost: String = Constants.baseHost,
                path: String = Constants.path,
                urlSession: URLSession = .shared) {
        Constants.apiKey = apiKey
        Constants.baseScheme = baseScheme
        Constants.baseHost = baseHost
        Constants.path = path
        self.urlSession = urlSession
    }
    
    public func getBalance(with state: BalanceState) async throws -> String {
        let endpoint = SmsActivateEndpoint.getBalance(state)
        let result = await sendRequest(session: urlSession, endpoint: endpoint, responseModel: String.self)
        let response = try result.get()
        if let balance = response.components(separatedBy: ":").last {
            return balance
        }
        throw SmsActivateError.badAnswer
    }
    
    public func getNumber(request: GetActivateNumberRequest) async throws -> (Int, Int) {
        let endpoint = SmsActivateEndpoint.getNumber(request)
        let result = await sendRequest(session: urlSession, endpoint: endpoint, responseModel: String.self)
        let response = try result.get()
        let components = response.components(separatedBy: ":")
        if components.count == 3,
           let id = Int(components[1]),
           let phone = Int(components[2]) {
            return (id, phone)
        }
        throw SmsActivateError.badAnswer
    }
    
    public func getStatus(id: Int) async throws -> (GetStatus, String?) {
        let endpoint = SmsActivateEndpoint.getStatus(id: id)
        let result = await sendRequest(session: urlSession, endpoint: endpoint, responseModel: String.self)
        let response = try result.get()
        let components = response.components(separatedBy: ":")
        if components.count == 2,
           let status = GetStatus(rawValue: components[0]) {
            let code: String = components[1]
            return (status, code)
        } else if components.count == 1,
                  let status = GetStatus(rawValue: components[0]) {
            return (status, nil)
        }
        throw SmsActivateError.badAnswer
    }
    
    public func getActiveActivations() async throws -> [ActiveActivation] {
        let endpoint = SmsActivateEndpoint.getActiveActivations
        let result = await sendRequest(session: urlSession, endpoint: endpoint, responseModel: ActiveActivationsResponse.self)
        let response = try result.get()
        if response.status == "success", let activations = response.activeActivations {
            return activations
        } else if response.status == "error" {
            throw SmsActivateError.noActivations
        }
        throw SmsActivateError.badAnswer
    }
    
    public func getCountries() async throws -> [CountryResponse] {
        let endpoint = SmsActivateEndpoint.getCountries
        let result = await sendRequest(session: urlSession, endpoint: endpoint, responseModel: [String: CountryResponse].self)
        let response = try result.get()
        return Array(response.values)
    }
    
    public func getOperators(countryId: Int) async throws -> [String] {
        let endpoint = SmsActivateEndpoint.getOperators(country: countryId)
        let result = await sendRequest(session: urlSession, endpoint: endpoint, responseModel: OperatorsResponse.self)
        let response = try result.get()
        if response.status == "success", let countryOperators = response.countryOperators {
            return Array(countryOperators.values).flatMap { $0 }
        } else if response.status == "error" {
            throw SmsActivateError.operatorsNotFound
        }
        throw SmsActivateError.badAnswer
    }
    
    @discardableResult
    public func setStatus(request: SetActivationStatusRequest) async throws -> SetActivationStatusResponse {
        let endpoint = SmsActivateEndpoint.setStatus(request)
        let result = await sendRequest(session: urlSession, endpoint: endpoint, responseModel: String.self)
        let response = try result.get()
        if let status = SetActivationStatusResponse(rawValue: response) {
            return status
        }
        throw SmsActivateError.badAnswer
    }
    
    public func waitForCode(id: Int, attempts: Int = 40, setStatusAfterCompletion: Bool = false) async throws -> String {
        if attempts <= 0 { throw SmsActivateError.noCodeReceived }
        
        let (status, code) = try await getStatus(id: id)
        switch status {
        case .ok, .waitRetry:
            guard let code else { throw SmsActivateError.badAnswer }
            
            if setStatusAfterCompletion {
                try await setStatus(request: SetActivationStatusRequest(id: id, status: .completeActivation))
            }
            return code
        case .waitCode, .waitResend:
            // Wait for 3 seconds before retrying
            try await Task.sleep(nanoseconds: 3 * 1_000_000_000)
            return try await waitForCode(id: id,
                                         attempts: attempts - 1,
                                         setStatusAfterCompletion: setStatusAfterCompletion)
        case .cancel:
            if setStatusAfterCompletion {
                try await setStatus(request: SetActivationStatusRequest(id: id, status: .cancelActivation))
            }
            throw SmsActivateError.activationCancelled
        }
    }
    
}
