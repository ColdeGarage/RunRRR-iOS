//
//  MainViewRouter.swift
//  RunRRR 2.0
//
//  Created by Jacky Huang on 2018/7/12.
//  Copyright © 2018年 ColdeGarage. All rights reserved.
//

import UIKit

class MainViewRouter: MainViewControllerOutput {
    var controller: MainViewController
    init(vc: MainViewController) {
        self.controller = vc
    }
    
    internal func checkIsLogin() -> Bool{
        let localUserDefault = UserDefaults.standard
        
        let isLogin = localUserDefault.bool(forKey: "RunRRR_Login")
        
        if (!isLogin) {
            UIApplication.shared.keyWindow?.rootViewController?.present(LoginViewController(), animated: true, completion: nil)
            return false
        }
        else {
            return true
        }
    }
}

protocol MainViewControllerOutput {
    func checkIsLogin() -> Bool
}
