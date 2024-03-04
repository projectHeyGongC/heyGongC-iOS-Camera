//
//  GCError.swift
//  heyGongC
//
//  Created by 김은서 on 12/27/23.
//

import Foundation
import Toast_Swift

/// 서버통신은 성공했으나 서버 내의 통신
public enum GCError: Error {
    /// 파라미터 이상
    case badRequest
    /// 유효하지 않은 토큰
    case unauthorized
    /// 새로운 로그인 존재
    case forbidden
    case internalServerError
    case notFoundCode
    case unKnown
    case errorJson
}

enum GCErrorCode: Int {
    case success                            = 200
    case badRequest                         = 400
    case unauthorized                       = 401
    case forbidden                          = 403
    case internalServerError                = 500
}

extension GCError {
    
    func processError(target: UIViewController) {
        switch self {
        case .badRequest:
            print("badRequest")
        case .unauthorized:
            print("unauthorized")
        case .forbidden:
            print("forbidden")
        case .internalServerError:
            print("InternalServerError")
        case .notFoundCode:
            print("notFoundCode")
        case .unKnown:
            print("unKnown")
        case .errorJson:
            print("errorJson")
        }
    }
    
    func showErrorMsg(target: UIView) {
        switch self {
        default:
            print("🪫🪫🪫🪫 \(self)")
            target.makeToast(Localized.ERROR_MSG.txt)
            
            break
        }
    }
}

