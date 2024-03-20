//
//  CameraModel.swift
//  heyGongC_Camera
//
//  Created by 장예지 on 3/20/24.
//

import Foundation

enum UserDefaultsKey: String {
    case accessToken
}

// MARK: Request Parameters
class CameraParam {
    struct RequestSubscribeData: Codable {
        var deviceId: String = Util.shared.uuid
        var deviceOs: String = "IOS"
        var modelName: String = Util.shared.deviceName
    }
    
    struct RequestStatusData: Codable {
        var battery: Int = Util.shared.batteryLevel
    }
}

// MARK: Response Structs
struct ConnectionResult: Codable {
    let isConnected: Bool?
}

struct StatusResult: Codable {
    let code, message: String?
}

struct CamearModel: Codable {
    enum Sensitivity: String, Codable {
        case LOW = "LOW"
        case HIGH = "HIGH"
    }
    
    enum CameraMode: String, Codable {
        case FRONT = "FRONT"
        case BACK = "BACK"
    }
    
    let sensitivity: Sensitivity?
    let cameraMode: CameraMode?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.sensitivity = try container.decodeIfPresent(CamearModel.Sensitivity.self, forKey: .sensitivity)
        self.cameraMode = try container.decodeIfPresent(CamearModel.CameraMode.self, forKey: .cameraMode)
    }
}

struct SoundOccurResult: Codable {
    let code, message: String?
}

// MARK: AccessToken
struct TokenModel: Codable {
    let accessToken: String?
}
