//
//  APIService.swift
//  heyGongC_Camera
//
//  Created by 장예지 on 3/1/24.
//

import Foundation
import Moya
import RxSwift

enum APIService {
    case token
}

extension APIService: TargetType {
    var baseURL: URL {
        return URL(string: "http://15.165.133.184/v1")!
    }
    
    var path: String {
        switch self {
        case .token:
            return "users/token"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .token:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .token:
            return .requestParameters(parameters: ["deviceId" : Util.shared.uuid], encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .token:
            return [
                "Content-Type": "text/plain",
                "Accept" : "text/plain"
            ]
        }
    }
}

class DeviceAPI {
    
    static let shared = DeviceAPI()
    
    private let deviceProvider = MoyaProvider<APIService>(plugins: [MoyaLoggingPlugin()])
    private let disposeBag = DisposeBag()
    
    enum NetworkResult<T> {
        case success(T?)
        case error(GCError)
    }
    
    public func networking<T:Codable>(type: T.Type = String.self) -> Single<NetworkResult<T>> {
        return Single<NetworkResult<T>>.create { single in
            self.deviceProvider.request(.token) { result in
                switch result {
                case .success(let response):
                    print("response: \(response)")
                    single(.success(self.judgeStatus(response: response, type: type)))
                case .failure(let error):
                    single(.failure(error))
                    return
                }
            }
            return Disposables.create()
        }
        
    }
    
    private func judgeStatus<T: Codable>(response: Response, type: T.Type = String.self) -> NetworkResult<T> {
        let decoder = JSONDecoder()
        switch response.statusCode {
        case 200:
            if let contentType = response.response?.allHeaderFields["Content-Type"] as? String {
                if contentType.contains("text/plain") {
                    guard let textData = String(data: response.data, encoding: .utf8) as? T else { return .success(nil) }
                    return .success(textData)
                } else if contentType.contains("application/json") {
                    guard let decodedData = try? decoder.decode(T.self, from: response.data) else { return .error(.errorJson) }
                    return .success(decodedData)
                }
                    return .success(nil)
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
