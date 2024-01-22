//
//  UIViewController+Ext.swift
//  heyGongC_Camera
//
//  Created by 장예지 on 1/22/24.
//

import Foundation
import UIKit

//화면 회전 잠금 코드
extension UIViewController {

    /// Lock your orientation
    func lockOrientation(_ orientation: UIInterfaceOrientationMask) {

        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.orientationLock = orientation
        }

        if #available(iOS 16.0, *) {
            self.setNeedsUpdateOfSupportedInterfaceOrientations()
        }
    }

    /// OPTIONAL Added method to adjust lock and rotate to the desired orientation
    func lockOrientation(
        _ allowOrientation: UIInterfaceOrientationMask,
        andRotateTo rotateOrientation: UIInterfaceOrientationMask) {
            
        self.lockOrientation(allowOrientation)

        if #available(iOS 16.0, *) {
            UIViewController.attemptRotationToDeviceOrientation()
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: rotateOrientation))

            self.setNeedsUpdateOfSupportedInterfaceOrientations()

        } else {

            UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
            UINavigationController.attemptRotationToDeviceOrientation()
        }
    }
}
