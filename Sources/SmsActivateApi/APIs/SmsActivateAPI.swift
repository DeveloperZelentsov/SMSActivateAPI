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
    /// - Parameter request: A GetNumberRequest object containing the phone number request information.
    /// - Returns: A tuple with two Int values, the first representing the activation ID, and the second representing the phone number.
    func getNumber(request: GetNumberRequest) async throws -> (Int, Int)
    
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
    /// - Parameter request: A SetStatusRequest object containing the activation status update information.
    /// - Returns: A SetStatusResponse object representing the response from the SMS Activate API.
    func setStatus(request: SetStatusRequest) async throws -> SetStatusResponse
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
    
    public func getNumber(request: GetNumberRequest) async throws -> (Int, Int) {
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
    
    public func setStatus(request: SetStatusRequest) async throws -> SetStatusResponse {
        let endpoint = SmsActivateEndpoint.setStatus(request)
        let result = await sendRequest(session: urlSession, endpoint: endpoint, responseModel: String.self)
        let response = try result.get()
        if let status = SetStatusResponse(rawValue: response) {
            return status
        }
        throw SmsActivateError.badAnswer
    }

}
