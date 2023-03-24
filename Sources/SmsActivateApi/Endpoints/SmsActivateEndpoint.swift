//
//  File.swift
//  
//
//  Created by Alexey on 24.03.2023.
//

import Foundation

public enum SmsActivateEndpoint {
    case getBalance(BalanceState)
    case getNumber(GetNumberRequest)
    
    case getStatus(id: Int)
    case getActiveActivations
    
    case setStatus(SetStatusRequest)
    
    case getOperators(country: Int?)
    case getCountries
}

extension SmsActivateEndpoint: CustomEndpoint {
    
    public var url: URL? {
        var urlComponents: URLComponents = .default
        urlComponents.queryItems = queryItems
        urlComponents.path = path
        return urlComponents.url
    }
    
    public var queryItems: [URLQueryItem]? {
        var items: [URLQueryItem] = [.init(name: "api_key", value: Constants.apiKey)]
        switch self {
        case .getBalance(let state):
            switch state {
            case .onlyBalance:
                items.append(.init(name: "action", value: "getBalance"))
            case .withCashback:
                items.append(.init(name: "action", value: "getBalanceAndCashBack"))
            }
        case .getNumber(let numberRequest):
            items.append(.init(name: "action", value: "getNumber"))
            items.append(.init(name: "service", value: numberRequest.service.rawValue))
            items.append(.init(name: "ref", value: numberRequest.ref))
            
            if let forward = numberRequest.forward {
                items.append(.init(name: "forward", value: forward.description))
            }
            
            if let operatorValue = numberRequest.operator {
                items.append(.init(name: "operator", value: operatorValue))
            }
            
            if let country = numberRequest.country {
                items.append(.init(name: "country", value: country.description))
            }
            
            if let phoneException = numberRequest.phoneException {
                items.append(.init(name: "phoneException", value: phoneException))
            }
            
            if let freePrice = numberRequest.freePrice {
                items.append(.init(name: "freePrice", value: freePrice.description))
            }
            
            if let maxPrice = numberRequest.maxPrice {
                items.append(.init(name: "maxPrice", value: maxPrice.description))
            }
            
            if let verification = numberRequest.verification {
                items.append(.init(name: "verification", value: verification.description))
            }
            
        case .getStatus(let id):
            items.append(.init(name: "action", value: "getStatus"))
            items.append(.init(name: "id", value: id.description))
        case .getActiveActivations:
            items.append(.init(name: "action", value: "getActiveActivations"))
            
        case .setStatus(let request):
            items.append(.init(name: "action", value: "setStatus"))
            items.append(.init(name: "id", value: request.id))
            items.append(.init(name: "status", value: String(request.status.rawValue)))
            if let forward = request.forward {
                items.append(.init(name: "forward", value: forward))
            }
            
        case .getOperators(let country):
            items.append(.init(name: "action", value: "getOperators"))
            if let country = country {
                items.append(.init(name: "country", value: country.description))
            }
        case .getCountries:
            items.append(.init(name: "action", value: "getCountries"))
        }
        return items
    }
    
    public var path: String {
        return Constants.path
    }
    
    public var method: HTTPRequestMethods {
        return .get
    }
    
    public var header: [String : String]? {
        return nil
    }
    
    public var body: BodyInfo? {
        return nil
    }
}
