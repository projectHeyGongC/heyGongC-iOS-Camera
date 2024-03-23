//
//  Push.swift
//  heyGongC
//
//  Created by 김은서 on 12/25/23.
//

#if canImport(UIKit)
import UIKit

public final class Push {
    public init() {}
    
    public class func configure(application: UIApplication, delegate: UNUserNotificationCenterDelegate?) {
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = delegate
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: { (granted, error) in
                    if granted {
                        print("사용자가 푸시를 허용했습니다")
                        DispatchQueue.main.async {
                            application.registerForRemoteNotifications()
                        }
                    } else {
                        print("사용자가 푸시를 거절했습니다")
                    }
                })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
    }
    
    public class func parse(application: UIApplication, notification: UNNotification, push: ([AnyHashable: Any]) -> Void) {
        application.applicationIconBadgeNumber = 0
        let userInfo = notification.request.content.userInfo
        if userInfo.keys.contains("gcm.message_id") {
            return
        } else {
            push(userInfo)
        }
    }
}
#endif
