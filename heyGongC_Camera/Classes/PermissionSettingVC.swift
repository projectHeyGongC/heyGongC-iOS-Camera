//
//  PermissionSettingVC.swift
//  heyGongC_Camera
//
//  Created by 장예지 on 1/19/24.
//

import Foundation
import UIKit
import SnapKit
import RxSwift
import SwiftyUserDefaults

class PermissionSettingVC: UIViewController {

    @IBOutlet weak var lblCameraRequired: UILabel!
    @IBOutlet weak var lblMicRequired: UILabel!
    @IBOutlet weak var btnAccept: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setAttributeString(label: lblCameraRequired)
        setAttributeString(label: lblMicRequired)
    }
    
    private func setAttributeString(label: UILabel){
        let attribute = NSMutableAttributedString(string: label.text ?? "")
        attribute.addAttribute(.foregroundColor, value: GCColor.C_006877, range: (label.text! as NSString).range(of: "필수") )
        label.attributedText = attribute
    }
    
}

