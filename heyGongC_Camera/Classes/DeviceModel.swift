//
//  DeviceModel.swift
//  heyGongC_Camera
//
//  Created by 장예지 on 3/1/24.
//

import Foundation

class DeviceParam {
    struct AccessTokenRequest: Codable {
        var deviceId = Util.getUUID()
    }
}
