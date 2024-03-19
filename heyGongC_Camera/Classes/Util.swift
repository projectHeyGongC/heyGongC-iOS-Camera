//
//  Util.swift
//  heyGongC_Camera
//
//  Created by 장예지 on 3/1/24.
//

import Foundation
import TAKUUID

class Util {
    
    private init(){
        UIDevice.current.isBatteryMonitoringEnabled = true
    }
    
    public static let shared = Util()
    
    //기기 UUID
    var uuid: String {
        TAKUUIDStorage.sharedInstance().migrate()
        let uuid = TAKUUIDStorage.sharedInstance().findOrCreate() ?? ""
        return uuid
    }
    
    //기기 모델명
    var deviceName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
    
    //배터리 잔여량
    var batteryLevel: Int? {
        return Int(UIDevice.current.batteryLevel) * 100
    }

}
