//
//  UIAlertController+Ext.swift
//  heyGongC_Camera
//
//  Created by 장예지 on 3/19/24.
//

import Foundation
import UIKit

extension UIAlertController {
    static func showAlertAction(vc: UIViewController? = UIApplication.shared.keyWindow?.visibleViewController, localized: Localized, confirm: (()->())? = nil, cancel: (()->())? = nil){
                
                guard let currentVc = vc else {
                    return
                }
                
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: localized.title, message: localized.txt, preferredStyle: .alert)
                    
                    if localized.confirmText != "" {
                        let confirmAction = UIAlertAction(title: localized.confirmText, style: .default){ action in
                            confirm?()
                        }
                        confirmAction.setValue(UIColor(red: 0/255, green: 104/255, blue: 119/255, alpha: 1), forKey: "titleTextColor")
                        alert.addAction(confirmAction)
                    }
                    
                    if localized.cancelText != "" {
                        let cancelAction = UIAlertAction(title: localized.cancelText, style: .cancel){ action in
                            cancel?()
                        }
                        cancelAction.setValue(UIColor(red: 0, green: 0, blue: 0, alpha: 0.5), forKey: "titleTextColor")
                        alert.addAction(cancelAction)
                    }
                    
                    currentVc.present(alert, animated: true, completion: nil)
                }
            }
}
