//
//  DefaultsKeys.swift
//  heyGongC
//
//  Created by 김은서 2023/12/25.
//

import Foundation
import SwiftyUserDefaults

extension DefaultsKeys {
    var FCM_TOKEN: DefaultsKey<String> { .init("FCM_TOKEN", defaultValue: "") }
}
