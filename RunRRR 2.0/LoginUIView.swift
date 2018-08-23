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
    
    let RunRRRLogoView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "ic_login")
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
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
    
    let showPasswordCheckBox : Checkbox = {
        let cb = Checkbox()
        cb.checkedBorderColor = .black
        cb.checkboxBackgroundColor = .black
        cb.borderStyle = .square
        cb.checkmarkColor = .white
        cb.checkmarkStyle = .cross
        cb.useHapticFeedback = true
        cb.addTarget(self, action: #selector(isShowPasswordCheckboxTapped(_:)), for: .valueChanged)
        return cb
    }()
    
    let showPasswordLabel: UILabel = {
        let label = UILabel()
        label.text = "顯示密碼"
        label.textColor = UIColor(hexString: "#282828")
        return label
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
        self.addSubview(showPasswordCheckBox)
        self.addSubview(showPasswordLabel)
        
        RunRRRLogoView.snp.makeConstraints{ make in
            make.centerX.equalTo(self)
            make.height.equalTo(self.snp.height).multipliedBy(0.4)
            make.width.equalTo(self.snp.width)
            make.top.equalTo(self).offset(20)
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
            make.top.equalTo(showPasswordCheckBox.snp.bottom).offset(20)
        }
        showPasswordCheckBox.snp.makeConstraints{(make) in
            make.left.equalTo(loginButton)
            make.top.equalTo(userPwdTextField.snp.bottom).offset(10)
            make.height.equalTo(24)
            make.width.equalTo(24)
        }
        
        showPasswordLabel.snp.makeConstraints{(make) in
            make.left.equalTo(showPasswordCheckBox.snp.right).offset(5)
            make.top.equalTo(showPasswordCheckBox)
            make.height.equalTo(showPasswordCheckBox)
            make.width.equalTo(userPwdTextField)
        }
    }
    
    @objc private func loginButtonTapped(_ sender: UIButton!) {
        self.loginViewDelegate?.didLoginButtonTapped(self.userEmailTextField, self.userPwdTextField)
    }
    
    @objc private func isShowPasswordCheckboxTapped(_ sender: Checkbox) {
        self.userPwdTextField.isSecureTextEntry = !sender.isChecked
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
