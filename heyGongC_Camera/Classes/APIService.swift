//
//  APIService.swift
//  heyGongC_Camera
//
//  Created by 장예지 on 3/1/24.
//

import Foundation
import Moya


class APIService {
    
    static let shared = APIService()
    
    let baseUrl = "http://15.165.133.184/v1/cameras"
    
    public func getHeader() -> [String: String] {
        return [
            "accept": "application/json",
            "Content-Type": "application/json"
        ]
    }
    
    public func judgeStatus<T: Codable>(response: Response, type: T.Type = String.self) -> NetworkResult<T> {
        let decoder = JSONDecoder()
        switch response.statusCode {
        case 200:
            if let contentType = response.response?.allHeaderFields["Content-Type"] as? String {
                if contentType.contains("text/plain") {
                    guard let textData = String(data: response.data, encoding: .utf8) as? T else { return .error(.errorEncoding) }
                    return .success(textData)
                } else if contentType.contains("application/json") {
                    guard let decodedData = try? decoder.decode(T.self, from: response.data) else { return .error(.errorDecoding) }
                    return .success(decodedData)
                }
                    return .error(.errorJson)
            }
            return .error(.errorJson)
        case 400:
            return .error(.badRequest)
        case 401:
            return .error(.unauthorized)
        case 403:
            return .error(.forbidden)
        case 500:
            return .error(.internalServerError)
        default:
            print("❗️❗️❗️❗️ networkFail")
            return .error(.notFoundCode)
        }
    }
}

public enum NetworkResult<T> {
    case success(T?)
    case error(GCError)
}
