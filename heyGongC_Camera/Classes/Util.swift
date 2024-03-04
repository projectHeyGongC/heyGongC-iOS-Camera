//
//  Util.swift
//  heyGongC_Camera
//
//  Created by 장예지 on 3/1/24.
//

import Foundation
import TAKUUID

class Util {
    static func getUUID() -> String{
        TAKUUIDStorage.sharedInstance().migrate()
        let uuid = TAKUUIDStorage.sharedInstance().findOrCreate() ?? ""
        return uuid
    }
}
