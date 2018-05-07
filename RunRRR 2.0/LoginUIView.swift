//
//  LoginUIView.swift
//  RunRRR 2.0
//
//  Created by Jacky Huang on 2018/5/6.
//  Copyright © 2018年 ColdeGarage. All rights reserved.
//

import UIKit
import SnapKit

class LoginUIView: UIView {
    var loginButtonDelegate: LoginButtonDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.white
        let loginButton = UIButton(type: .system)
        loginButton.layer.cornerRadius = 4
        loginButton.setTitle("Login", for: .normal)
        self.addSubview(loginButton)
        
        loginButton.snp.makeConstraints{ make in
            make.centerX.equalTo(self)
            make.height.equalTo(64)
            make.width.equalTo(self.snp.width).multipliedBy(0.3)
            make.bottom.equalTo(self.snp.bottom).offset(-80)
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
