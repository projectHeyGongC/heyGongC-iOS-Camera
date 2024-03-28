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
import RxOptional
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
        setErrorHandler()
        bindAction()
        
        //소리감지 테스트 위해 추가
        let tapGesture = UITapGestureRecognizer()
        viewQRCode.addGestureRecognizer(tapGesture)
        tapGesture.addTarget(self, action: #selector(didTapView))
        
        //카메라 연동 되어있는지 체크
        viewModel.checkDevicePaired()
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
            .observe(on: MainScheduler.instance)
            .bind { [weak self] image in
                guard let self else { return }
                
                guard let image = image else {
                    showAlertForQRGenerationFailure()
                    return
                }
                
                imgViewQRCode.image = image
                viewModel.hiddenQRCode.accept(false)
                
            }
            .disposed(by: viewModel.bag)
        
        viewModel.hiddenQRCode
            .bind {
                print("value: \($0)")
                self.viewQRCode.isHidden = $0
            }
            .disposed(by: viewModel.bag)
    }
    
    @objc func didTapView(){
        isTappedViewQRCode.toggle()
        print("isTappedViewQRCode:\(isTappedViewQRCode)")
        viewModel.successPaired.accept(isTappedViewQRCode)
    }
    
    
    private func showAlertForQRGenerationFailure() {
        UIAlertController.showAlertAction(vc: self, localized: .DLG_REGENERATE_QRCODE) {
            self.viewModel.getQRImage()
        } cancel: {
            self.view.makeToast(Localized.ERROR_MSG.txt)
        }
    }
}

extension CameraVC {
    private func setErrorHandler() {
            viewModel.errorHandler
                .filterNil()
                .bind { [weak self] in
                    guard let self else { return }
                    setErrorHandler(error: $0)
                }
                .disposed(by: viewModel.bag)
        }
        
        private func setErrorHandler(error: Error?) {
            
            guard let e = error as? GCError else {
                // 알 수 없는 에러
                print(error?.localizedDescription ?? "")
                GCError.notFoundCode.showErrorMsg(target: self.view)
                return
            }
            
            switch e {
            case .unauthorized:
                break
            default:
                print("🔋🔋🔋🔋 \(error?.localizedDescription ?? "")")
                e.showErrorMsg(target: self.view)
                break
            }
        }
}
