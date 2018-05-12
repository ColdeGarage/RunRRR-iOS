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
    var loginViewDelegate: LoginViewDelegate?
    
    let RunRRRLogoView = UIImageView()
    
    let userEmailTextField: UITextField = {
        let userEmailTextField = UITextField()
        userEmailTextField.keyboardType = .emailAddress
        userEmailTextField.layer.borderColor = UIColor(hexString: "#E2E4E8").cgColor
        userEmailTextField.layer.borderWidth = CGFloat(1)
        userEmailTextField.autocapitalizationType = .none
        userEmailTextField.placeholder = "Email Address"
        return userEmailTextField
    }()
    
    let userPwdTextField: UITextField = {
        let userPwdTextField = UITextField()
        userPwdTextField.keyboardType = .default
        userPwdTextField.isSecureTextEntry = true
        userPwdTextField.layer.borderColor = UIColor(hexString: "#E2E4E8").cgColor
        userPwdTextField.layer.borderWidth = CGFloat(1)
        userPwdTextField.placeholder = "Password"
        return userPwdTextField
    }()
    
    let loginButton: UIButton = {
        let loginButton = UIButton(type: .system)
        loginButton.backgroundColor = UIColor.black
        loginButton.setTitleColor(UIColor.white, for: .normal)
        loginButton.layer.cornerRadius = 4
        loginButton.setTitle("Login", for: .normal)
        loginButton.addTarget(self, action: #selector(loginButtonTapped(_:)), for: .touchUpInside)
        return loginButton
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor(hexString: "#FAFBFC")

        self.addSubview(RunRRRLogoView)
        self.addSubview(userEmailTextField)
        self.addSubview(userPwdTextField)
        self.addSubview(loginButton)
        
        RunRRRLogoView.snp.makeConstraints{ make in
            make.centerX.equalTo(self)
            make.height.equalTo(self.snp.height).multipliedBy(0.5)
            make.width.equalTo(self.snp.width)
            make.top.equalTo(self)
        }
        
        userEmailTextField.snp.makeConstraints{ make in
            make.centerX.equalTo(self)
            make.height.equalTo(32)
            make.width.equalTo(self.snp.width).multipliedBy(0.7)
            make.top.equalTo(RunRRRLogoView.snp.bottom).offset(20)
        }
        
        userPwdTextField.snp.makeConstraints{ make in
            make.centerX.equalTo(self)
            make.height.equalTo(32)
            make.width.equalTo(self.snp.width).multipliedBy(0.7)
            make.top.equalTo(userEmailTextField.snp.bottom).offset(16)
        }
        
        loginButton.snp.makeConstraints{ make in
            make.centerX.equalTo(self)
            make.height.equalTo(40)
            make.width.equalTo(self.snp.width).multipliedBy(0.7)
            make.top.equalTo(userPwdTextField.snp.bottom).offset(20)
        }
    }
    
    @objc private func loginButtonTapped(_ sender: UIButton!) {
        self.loginViewDelegate?.didLoginButtonTapped(self.userEmailTextField, self.userPwdTextField)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
