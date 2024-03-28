//
//  CameraModel.swift
//  heyGongC_Camera
//
//  Created by 장예지 on 3/20/24.
//

import Foundation
import SwiftyUserDefaults

enum UserDefaultsKey: String {
    case accessToken
}

// MARK: Request Parameters
class CameraParam {
    struct RequestSubscribeData: Codable {
        var deviceId: String = Util.shared.uuid
        var modelName: String = Util.shared.deviceName
        var deviceOs: String = "IOS"
        var fcmToken: String = Defaults.FCM_TOKEN
    }
    
    struct RequestStatusData: Codable {
        var battery: Int = Util.shared.batteryLevel
        var temperature: Int = 0
    }
}

// MARK: Response Structs
struct CameraPairedResponse: Codable {
    let isPaired: Bool?
}

struct StatusResult: Codable {
    let code, message: String?
}

struct CameraDeviceSettingResponse: Codable {
    enum Sensitivity: String, Codable {
        case VERYLOW = "VERYLOW"
        case LOW = "LOW"
        case NOMAL = "NOMAL"
        case HIGH = "HIGH"
        case VERYHIGH = "VERYHIGH"
    }
    
    enum CameraMode: String, Codable {
        case FRONT = "FRONT"
        case BACK = "BACK"
    }
    
    let sensitivity: Sensitivity?
    let cameraMode: CameraMode?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.sensitivity = try container.decodeIfPresent(CameraDeviceSettingResponse.Sensitivity.self, forKey: .sensitivity)
        self.cameraMode = try container.decodeIfPresent(CameraDeviceSettingResponse.CameraMode.self, forKey: .cameraMode)
    }
}

struct SoundOccurResult: Codable {
    let code, message: String?
}

// MARK: AccessToken
struct CameraSubscribeResponse: Codable {
    let accessToken: String?
}
