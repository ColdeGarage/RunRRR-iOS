//
//  ViewController.swift
//  RunRRR 2.0
//
//  Created by Jacky Huang on 2018/4/22.
//  Copyright © 2018年 ColdeGarage. All rights reserved.
//

import UIKit
import SnapKit

class LoginViewController: UIViewController, LoginViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.backgroundColor = UIColor.white
        viewInit()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewInit() {
        let loginUIView = LoginUIView()
        loginUIView.loginViewDelegate = self
        
        let tap: UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.hideKeyboard))
        tap.cancelsTouchesInView = false
        loginUIView.addGestureRecognizer(tap)
        
        view.addSubview(loginUIView)
        
        loginUIView.snp.makeConstraints{ (make) in
            make.bottom.equalTo(view)
            make.left.equalTo(view)
            make.right.equalTo(view)
            
            if #available(iOS 11, *) {
                make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin)
            }
            else {
                make.top.equalTo(view.snp.topMargin)
            }
        }
    }
    
    internal func didLoginButtonTapped(_ userEmailTextField: UITextField, _ userPwdTextField: UITextField) {
        let userEmail: String = userEmailTextField.text!
        let userPwd: String = userPwdTextField.text!
        
        let loginHelper = LoginAPI(userEmail, userPwd)
        
        loginHelper.checkAndLogin({ result in
            switch (result){
            case .succeed:
                print("Login Successfully")
                self.dismiss(animated: false, completion: nil)
            case .emptyPwd:
                print("Password is Empty!")
                self.showAlertWindow(title: "Login Failed", message: "Please enter your password.")
            case .emptyEmail:
                print("Email is Empty!")
                self.showAlertWindow(title: "Login Failed", message: "Please enter your email.")
            case .wrongEmailOrPwd:
                print("Wrong Email or Password")
                self.showAlertWindow(title: "Login Failed", message: "The email or password is incorrect.")
            case .error:
                print("Error")
                self.showAlertWindow(title: "Login Failed", message: "Oops, something went wrong.\nWait for two minutes!")
            }
        })
        print("Login Button Tapped")// present(<#T##viewControllerToPresent: UIViewController##UIViewController#>, animated: <#T##Bool#>, completion: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>)
    }
}

protocol LoginViewDelegate {
    func didLoginButtonTapped(_: UITextField, _: UITextField)
}


