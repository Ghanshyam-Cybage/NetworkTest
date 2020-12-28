//
//  CovidDataParser.swift
//  NetworkingTest
//
//  Created by Ghanshyam Maliwal on 26/09/20.
//  Copyright © 2020 Ghanshyam Maliwal. All rights reserved.
//

import Foundation

struct CovidDataModel : Decodable {
    
    // MARK: - Instance properties
    let confirmedCount : Int
    let deathCount : Int
    let recoveredCount : Int
    var countryIndex : Int?
    
    // MARK: - Cusomized keys for parsing
    enum CovidKeys : String, CodingKey {
        case confirmedCount = "Confirmed"
        case deatchCount = "Deaths"
        case recoveredCount = "Recovered"
    }
    
    // MARK: - Intializer requirement from Decodable protocol
    init(from decoder: Decoder) throws {
        let dataContainer = try decoder.container(keyedBy: CovidKeys.self)
        confirmedCount = try dataContainer.decode(Int.self, forKey: .confirmedCount)
        deathCount = try dataContainer.decode(Int.self, forKey: .deatchCount)
        recoveredCount = try dataContainer.decode(Int.self, forKey: .recoveredCount)
    }
}

struct CovidDataParser {
    
    // MARK: - Methods
    func parse(responseData data: Data) -> CovidDataModel? {
        do {
            let decodedObject = try JSONDecoder().decode([CovidDataModel].self, from: data)
            return decodedObject.first
        } catch {
            return nil
        }
    }
}

