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
    @IBOutlet weak var lblAudioRequired: UILabel!
    @IBOutlet weak var btnAccept: UIButton!
    @IBOutlet weak var viewPermission: UIView!
    
    private let viewModel = PermissionSettingVM()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setAttributeString(label: lblCameraRequired)
        setAttributeString(label: lblAudioRequired)
        setObservables()
        addAction()
    }
    
    private func setObservables(){
        Observable.combineLatest(viewModel.cameraPermissionRelay, viewModel.audioPermissionRelay)
        {$0 && $1}
            .subscribe { [weak self] isEnabled in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.btnAccept.backgroundColor = isEnabled ? GCColor.C_FFC000 : GCColor.C_CACACA
                    self.btnAccept.isEnabled = isEnabled
                }
            }
            .disposed(by: viewModel.bag)
        
        btnAccept.rx.tap
            .bind{
                let storyboard = UIStoryboard.init(name: "Camera", bundle: nil)
                guard let vc = storyboard.instantiateViewController(withIdentifier: "Camera")as? CameraVC else {return}
                
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
            }
            .disposed(by: viewModel.bag)
    }
    
    private func setAttributeString(label: UILabel){
        let attribute = NSMutableAttributedString(string: label.text ?? "")
        attribute.addAttribute(.foregroundColor, value: GCColor.C_006877, range: (label.text! as NSString).range(of: "필수") )
        label.attributedText = attribute
    }
    
    private func addAction(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openSettings))
        
        viewPermission.addGestureRecognizer(tapGesture)
    }
    
    @objc func openSettings(){
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}
