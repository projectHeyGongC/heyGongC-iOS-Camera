//
//  Camera.swift
//  heyGongC_Camera
//
//  Created by 장예지 on 1/19/24.
//

import Foundation
import UIKit
import SnapKit
import RxSwift
import RxCocoa
import SwiftyUserDefaults
import CoreImage.CIFilterBuiltins
import AVFoundation
import Toast_Swift

class CameraVC: UIViewController {
    
    @IBOutlet weak var viewQRCode: UIView!
    @IBOutlet weak var imgViewQRCode: UIImageView!
    
    // MARK: - properties
    private var viewModel = CameraVM()
    private var isTappedViewQRCode: Bool = false
    
    // MARK: - methods
    override func viewDidLoad() {
        super.viewDidLoad()
    
        setUI()
        bindAction()
        
        //소리감지 테스트 위해 추가
        let tapGesture = UITapGestureRecognizer()
        viewQRCode.addGestureRecognizer(tapGesture)
        tapGesture.addTarget(self, action: #selector(didTapView))
        
        viewModel.checkDeviceConnection()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        viewModel.setCameraFrame(frame: view.bounds)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.global(qos: .background).async{
            self.viewModel.startCamera()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("view did disappear")
        super.viewDidDisappear(animated)
        self.viewModel.stopCamera()
    }
    
    private func setUI(){
        lockOrientation(.landscape)
        view.layer.addSublayer(viewModel.cameraLayer)
        view.bringSubviewToFront(self.viewQRCode)
    }
    
    private func bindAction(){
        viewModel.successGenerateQRImage
            .bind { [weak self] image in
                guard let self else { return }
                
                guard let image = image else {
                    self.showAlertForQRGenerationFailure()
                    return
                }
                
                imgViewQRCode.image = image
                viewModel.hiddenQRCode.accept(false)
                
            }
            .disposed(by: viewModel.bag)
        
        viewModel.hiddenQRCode
            .bind {
                self.viewQRCode.isHidden = $0
            }
            .disposed(by: viewModel.bag)
        
    }
    
    @objc func didTapView(){
        isTappedViewQRCode.toggle()
        print("isTappedViewQRCode:\(isTappedViewQRCode)")
        viewModel.successConnectDevice.accept(isTappedViewQRCode)
    }
    
    
    private func showAlertForQRGenerationFailure() {
        UIAlertController.showAlertAction(vc: self, localized: .DLG_REGENERATE_QRCODE) {
            self.viewModel.getQRImage()
        } cancel: {
            self.view.makeToast(Localized.ERROR_MSG.txt)
        }
    }
}
