//
//  SplashView.swift
//  heyGongC_Camera
//
//  Created by 장예지 on 3/5/24.
//

import Foundation
import UIKit
import RxSwift

class SplashView: UIViewController {
    
    private let viewModel = InitialSettingViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
    func bind(){
        viewModel.isValidAccessTokenRelay.bind { [weak self] in
            guard let self else { return}
            if $0 {
                viewModel.checkAllPermissions()
            } else {
                //무슨처리?
            }
        }
        .disposed(by: viewModel.bag)
        
        Observable.combineLatest(viewModel.isValidAccessTokenRelay, viewModel.checkAllPermsiionsRelay)
            .map{ $0 && $1 }
            .subscribe { [weak self] in
                guard let self else { return }
                if $0 {
                    let storyboard = UIStoryboard.init(name: "QRCodeGenerator", bundle: nil)
                    guard let vc = storyboard.instantiateViewController(withIdentifier: "QRCodeGenerator")as? QRCodeGeneratorVC else {return}
                    
                    vc.modalPresentationStyle = .fullScreen
                    present(vc, animated: true, completion: nil)
                } else {
                    let storyboard = UIStoryboard.init(name: "PermissionSetting", bundle: nil)
                    guard let vc = storyboard.instantiateViewController(withIdentifier: "PermissionSetting")as? PermissionSettingVC else {return}
    
                    vc.modalPresentationStyle = .fullScreen
                    present(vc, animated: true, completion: nil)
                }
            }
            .disposed(by: viewModel.bag)
    }
}
