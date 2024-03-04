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
        return URL(string: "http://13.125.159.97/v1/")!
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
            return .requestJSONEncodable(DeviceParam.AccessTokenRequest())
        }
    }
    
    var headers: [String : String]? {
        return [
            "accept": "application/json",
            "Content-Type": "application/json"
        ]
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
    
    public func networking(completion: @escaping (NetworkResult<Any>) -> Void){
        deviceProvider.rx.request(.token)
            .subscribe { result in
                switch result {
                case .success(let response):
                    switch response.statusCode {
                    case 200:
                        completion(.success(try? response.map(String.self)))
                    case 400:
                        completion(.error(.badRequest))
                    case 401:
                        completion(.error(.unauthorized))
                    case 403:
                        completion(.error(.forbidden))
                    case 500:
                        completion(.error(.internalServerError))
                    default:
                        print("❗️❗️❗️❗️ networkFail")
                        completion(.error(.notFoundCode))
                    }
                case .failure(let error):
                    print("\(error)")
                }
            }
            .disposed(by: disposeBag)
    }
}
