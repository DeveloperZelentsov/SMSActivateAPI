//
//  File.swift
//  
//
//  Created by Alexey on 24.03.2023.
//

import Foundation

public struct CountryResponse: Codable, Equatable {
    
    public let id: Int
    public let rus: String
    public let eng: String
    public let chn: String
    public let visible: Bool
    public let retry: Bool
    public let rent: Bool
    public let multiService: Bool
    
    public init(id: Int, rus: String, eng: String, chn: String, visible: Bool, retry: Bool, rent: Bool, multiService: Bool) {
        self.id = id
        self.rus = rus
        self.eng = eng
        self.chn = chn
        self.visible = visible
        self.retry = retry
        self.rent = rent
        self.multiService = multiService
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        rus = try container.decode(String.self, forKey: .rus)
        eng = try container.decode(String.self, forKey: .eng)
        chn = try container.decode(String.self, forKey: .chn)
        
        if let visibleInt = try? container.decode(Int.self, forKey: .visible) {
            visible = visibleInt != 0
        } else {
            visible = try container.decode(Bool.self, forKey: .visible)
        }
        
        if let retryInt = try? container.decode(Int.self, forKey: .retry) {
            retry = retryInt != 0
        } else {
            retry = try container.decode(Bool.self, forKey: .retry)
        }
        
        if let rentInt = try? container.decode(Int.self, forKey: .rent) {
            rent = rentInt != 0
        } else {
            rent = try container.decode(Bool.self, forKey: .rent)
        }
        
        if let multiServiceInt = try? container.decode(Int.self, forKey: .multiService) {
            multiService = multiServiceInt != 0
        } else {
            multiService = try container.decode(Bool.self, forKey: .multiService)
        }
    }
}
