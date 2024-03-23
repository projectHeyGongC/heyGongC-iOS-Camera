//
//  CVal.swift
//  heyGongC_Camera
//
//  Created by 김은서 on 3/23/24.
//

import Foundation

//MARK: - enum
enum GCNotification {
    case Push
    case DeepLink
    case Airplane
    case GoHome
    
    var name: Notification.Name {
        switch self {
        case .Push: return Notification.Name("kPushRecv")
        case .DeepLink: return Notification.Name("kDeepLinkRecv")
        case .Airplane: return Notification.Name("Airplane")
        case .GoHome: return Notification.Name("GoHome")
        }
    }
}
