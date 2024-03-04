//
//  Localized.swift
//  heyGongC
//
//  Created by 김은서 2023/12/25.
//

import Foundation
import SwiftyUserDefaults

// MARK: - Localized
enum Localized {
    case ERROR_MSG
    case MONITORING_CAMERA_OFF
    case MONITORING_CAMERA_ON
    case MONITORING_NOISE_ON
    case MONITORING_NOISE_OFF
    case DLG_DISCONNECTED_ALL_DIVICES
    case DLG_DELETE_USER
    case DLG_LOGOUT
    case DLG_NOTIFICATION_ON
    case DLG_NOTIFICATION_OFF
    case DLG_TEST
    case DLG_EXPIRED

    /**
     *  다국어 처리
     */
    var txt: String {
        switch self {
        case .ERROR_MSG:
            return "잠시 후 시도해주세요"
        case .MONITORING_CAMERA_OFF:
            return "카메라가 꺼져 있습니다."
        case .MONITORING_CAMERA_ON:
            return "집 이미지를 클릭하면 모니터링이 시작됩니다."
        case .MONITORING_NOISE_ON:
            return "소리 감지 모드 on"
        case .MONITORING_NOISE_OFF:
            return "소리 감지 모드 off"
        case .DLG_TEST:
            return "test"
        case .DLG_EXPIRED:
            return "재로그인 진행합니다."
        default:
            return ""
        }
    }
    
    var title: String {
        switch self {
        case .DLG_TEST:
            return "testTitle"
        case .DLG_DISCONNECTED_ALL_DIVICES:
            return "모든 기기 연동을 해제할까요?\n기존 데이터가 모두 삭제됩니다"
        case .DLG_DELETE_USER:
            return "회원 탈퇴를 진행합니다\n기존 데이터가 모두 삭제됩니다"
        case .DLG_LOGOUT:
            return "로그아웃 하시겠습니까?"
        case .DLG_NOTIFICATION_ON:
            return "알림이 설정되었습니다"
        case .DLG_NOTIFICATION_OFF:
            return "알림이 거부되었습니다"
        case .DLG_EXPIRED:
            return "세션 만료"
        default: return ""
        }
    }
    
    var confirmText: String {
        switch self {
        case .DLG_TEST, .DLG_DISCONNECTED_ALL_DIVICES, .DLG_DELETE_USER:
            return "확인"
        case .DLG_LOGOUT:
            return "예"
        case .DLG_NOTIFICATION_ON, .DLG_NOTIFICATION_OFF,  .DLG_EXPIRED:
            return "확인"
        default: return ""
        }
    }
    
    var cancelText: String {
        switch self {
        case .DLG_TEST:
            return "취소"
        case .DLG_DISCONNECTED_ALL_DIVICES:
            return "취소"
        case .DLG_DELETE_USER:
            return "취소"
        case .DLG_LOGOUT:
            return "아니요"
        default: return ""
        }
    }
}


