//
//  CameraAPI.swift
//  heyGongC_Camera
//
//  Created by 장예지 on 3/20/24.
//

import Foundation
import Moya
import RxSwift

enum CameraService {
    case subscribe(param: CameraParam.RequestSubscribeData)
    case updateStatus(param: CameraParam.RequestStatusData)
    case inquireStatus
    case settings
    case soundOccur
}

extension CameraService : TargetType, AccessTokenAuthorizable {
    
    var authorizationType: Moya.AuthorizationType? {
        switch self {
            
        case .subscribe(param: _):
            return .none
        default:
            return .bearer
        }
    }
    
    var baseURL: URL {
        return URL(string: APIService.shared.baseUrl)!
    }
    
    var path: String {
        switch self {
        case .subscribe(param: _):
            return "/subscribe"
        case .updateStatus(param: _), .inquireStatus:
            return "/status"
        case .settings:
            return "/settings"
        case .soundOccur:
            return "sound/occur"
        }
    }
    
    var method: Moya.Method {
        switch self {
            
        case .subscribe(param: _):
            return .post
        case .updateStatus(param: _):
            return .put
        case .inquireStatus, .settings, .soundOccur:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .subscribe(param: let param):
            return .requestJSONEncodable(param)
        case .updateStatus(param: let param):
            return .requestJSONEncodable(param)
        case .inquireStatus, .settings, .soundOccur:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        return APIService.shared.getHeader()
    }
}

class CameraAPI {
    
    static let shared = CameraAPI()
    private var cameraProvider = MoyaProvider<CameraService>(plugins: [MoyaLoggingPlugin()])
    private let disposeBag = DisposeBag()
    let tokenClosure: (TargetType) -> String = { _ in
        return UserDefaults.standard.string(forKey: UserDefaultsKey.accessToken.rawValue) ?? ""
    }
    
    private init() {
        cameraProvider = MoyaProvider<CameraService>(plugins: [MoyaLoggingPlugin(), AccessTokenPlugin(tokenClosure: tokenClosure)])
    }
    
    
    public func networking<T:Codable>(cameraService: CameraService, type: T.Type = String.self) -> Single<NetworkResult<T>> {
        return Single<NetworkResult<T>>.create { single in
            self.cameraProvider.request(cameraService) { result in
                switch result {
                case .success(let response):
                    print("response: \(response)")
                    let networkResult = APIService.shared.judgeStatus(response: response, type: T.self)
                    single(.success(networkResult))
                case .failure(let error):
                    single(.failure(error))
                    return
                }
            }
            return Disposables.create()
        }
        
    }
}
