//
//  DefaultsKeys+Ext.swift
//  heyGongC_Camera
//
//  Created by 장예지 on 3/5/24.
//

import Foundation
import SwiftyUserDefaults

extension DefaultsKeys {
    var ACCESS_TOKEN: DefaultsKey<String> { .init("ACCESS_TOKEN", defaultValue:"") }
}
