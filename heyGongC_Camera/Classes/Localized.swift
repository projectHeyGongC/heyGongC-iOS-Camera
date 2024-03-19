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
    case DLG_REGENERATE_QRCODE
    
    /**
     *  다국어 처리
     */
    var txt: String {
        switch self {
        case .ERROR_MSG:
            return "잠시 후 시도해주세요"
        default:
            return ""
        }
    }
    
    var title: String {
        switch self {
        case .DLG_REGENERATE_QRCODE:
            return "QR코드 생성에 실패했습니다."
        default: return ""
        }
    }
    
    var confirmText: String {
        switch self {
        case .DLG_REGENERATE_QRCODE:
            return "재생성"
        default: return ""
        }
    }
    
    var cancelText: String {
        switch self {
        case .DLG_REGENERATE_QRCODE:
            return "취소"
        default: return ""
        }
    }
}


