//
//  NetworkManager.swift
//  MapkitAndWeather
//
//  Created by youngkyun park on 2/3/25.
//

import Foundation

import Alamofire

enum OpenWeatherRequest {
    
    case weatherInfo(lat: String, lon: String)
    
    
    var baseURL: String {
        "https://api.openweathermap.org/data/2.5/weather"
    }
    
    var endPoint: URL {
        switch self {
        case .weatherInfo:
            return URL(string: baseURL)!
        }
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var prarmeter: Parameters? {
        switch self {
        case let .weatherInfo(lat, lon):
            let parameters = ["lat": lat, "lon": lon, "appid": APIKey.APIKey, "units": "Metric"]
            return parameters
        }
        
    }
}


class NetworkManager {
    static let shared = NetworkManager()
    
    private init() { }
    
    
    func callRequest(api: OpenWeatherRequest ,completionHandler: @escaping (Result<OpenWeather, AFError>) -> Void ) {
        
        AF.request(api.endPoint, method: api.method,parameters: api.prarmeter, encoding: URLEncoding(destination: .queryString)).responseDecodable(of: OpenWeather.self) { response in
            switch response.result {
            case .success(let value):
                print(value)
                completionHandler(.success(value))
            case .failure(let error):
                print(error)
                completionHandler(.failure(error))
            }
        }
    }
}
        
