//
//  OpenWeatherStruct.swift
//  MapkitAndWeather
//
//  Created by youngkyun park on 2/3/25.
//

import Foundation


struct OpenWeather: Decodable {
    let main: Main
    let wind: Wind
}

struct Main: Decodable {
    let temp: Float
    let tempMin: Float
    let tempMax: Float
    let humidity: Int

    
    enum CodingKeys: String, CodingKey {
        case temp
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case humidity
    }

}

struct Wind: Decodable {
    let speed: Float
    
}
