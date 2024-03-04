//
//  QRCodeGeneratorVM.swift
//  heyGongC_Camera
//
//  Created by 장예지 on 1/19/24.
//

import Foundation
import UIKit

class QRCodeGeneratorVM {
    
    //QR코드 기기 UUID
    private var qrData: String?
    
    public func generateQRCodeData()-> Data? {
        let device = UIDevice.current
        let selName = "_\("deviceInfo")ForKey:"
        let selector = NSSelectorFromString(selName)
        
        if device.responds(to: selector){
            let modelName = String(describing: device.perform(selector, with: "marketing-name").takeRetainedValue())
            qrData = Util.getUUID() + " \(modelName)"
            return qrData?.data(using: .utf8)
        }
            return nil
    }
}
