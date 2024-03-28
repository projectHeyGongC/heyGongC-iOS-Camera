//
//  SplashView.swift
//  heyGongC_Camera
//
//  Created by 장예지 on 3/5/24.
//

import Foundation
import UIKit
import RxSwift
import RxOptional

class SplashView: UIViewController {
    
    private let viewModel = InitialSettingViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        setErrorHandler()
        
        self.viewModel.isValidAccessToken()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func bind(){
        viewModel.isValidAccessTokenRelay
            .filter{ $0 == true}
            .bind { [weak self] _ in
                guard let self else { return }
                
                viewModel.checkAllPermissions {
                    let storyboard = $0 ? UIStoryboard.init(name: "Camera", bundle: nil) : UIStoryboard.init(name: "PermissionSetting", bundle: nil)
                    
                    guard let vc = $0 ? storyboard.instantiateViewController(withIdentifier: "Camera") as? CameraVC : storyboard.instantiateViewController(withIdentifier: "PermissionSetting") as? PermissionSettingVC else { return }
                    
                    vc.modalPresentationStyle = .fullScreen
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0){
                        self.present(vc, animated: true, completion: nil)
                    }
                    
                }
            }
            .disposed(by: viewModel.bag)
    }
    
    
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
