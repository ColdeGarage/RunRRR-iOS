//
//  LoginViewController.swift
//  RunRRR
//
//  Created by Jacky Huang on 2017/3/3.
//  Copyright © 2017年 EEECamp. All rights reserved.
//
import Alamofire
import SwiftyJSON
import UIKit
import Foundation

class LoginViewController: UIViewController {

    @IBOutlet weak var loginStack: UIStackView!
    // MARK: Outlet
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var accountTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var aboutUsButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initLoginAppearance()
        self.hideKeyboardWhenTappedAround()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Action-LoginButtonTapped
    @IBAction func LoginButtonTapped(_ sender: Any) {
        let userAccount = accountTextField.text! as String
        let userPassword = passwordTextField.text! as String
        if(userAccount.isEmpty){
            showMessage(title:"Error", message: "Please enter your account.")
        }else if(userPassword.isEmpty){
            showMessage(title:"Error", message: "Please enter your password.")
        }else{
            // Auth
            userLogin(account: userAccount, password: userPassword)
        }
        //Checking both textfields are not emptys

    }
    
    override func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    override func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func initLoginAppearance(){
        self.view.addConstraintWithFormat(format: "H:|-50-[v0]-50-|", views: logoImage)
        self.view.addConstraintWithFormat(format: "H:|-40-[v0]-40-|", views: loginStack)
        self.view.addConstraintWithFormat(format: "H:|-20-[v0]-20-|", views: loginButton)
        self.view.addConstraintWithFormat(format: "H:|-80-[v0]-80-|", views: aboutUsButton)
//        self.view.addConstraintWithFormat(format: "H:|-20-[v0]-20-|", views: passwordTextField)
//        self.view.addConstraintWithFormat(format: "H:|-20-[v0]-20-|", views: accountTextField)
        
        self.view.addConstraintWithFormat(format: "V:|-10-[v0(\(self.view.frame.height/2))]", views: logoImage)
        self.view.addConstraintWithFormat(format: "V:[v0]-8-[v1]-10-[v2(45)]", views: logoImage, loginStack, loginButton)
        self.view.addConstraintWithFormat(format: "V:[v0(50)]-0-|", views: aboutUsButton)
        
        logoImage.image = UIImage(named: "RunRRR")
        
        loginButton.layer.cornerRadius = 5
        
//        let paddingView = UIView(frame: CGRect(x:0, y:0, width:10, height:self.accountTextField.frame.height))
        accountTextField.layer.cornerRadius = 0
        accountTextField.layer.borderWidth = CGFloat(1)
        accountTextField.layer.borderColor = UIColor.white.cgColor
//        accountTextField.leftView = paddingView
//        accountTextField.leftViewMode = .always
        
        passwordTextField.layer.cornerRadius = 0
        passwordTextField.layer.borderWidth = CGFloat(1)
        passwordTextField.layer.borderColor = UIColor.white.cgColor
//        passwordTextField.leftView = paddingView
//        passwordTextField.leftViewMode = .always
    }
    
    private func userLogin(account: String, password: String) -> Void{
        /*let loginURL="file:///Users/jackyhuang/Desktop/login.json"*/
        var isLogin : Bool = false
        let loginInfo : [String:Any] = ["email":account, "password":password]
        let LocalUserDefault = UserDefaults.standard
        Alamofire.request("\(Config.HOST):\(Config.PORT)/\(Config.API_PATH)/member/login", method: .post, parameters: loginInfo).responseJSON{ response in
            if ((response.result.value) != nil) {
                let userInfoJson = JSON(response.result.value!)
                if(!userInfoJson["payload"]["correct"].boolValue){
                    isLogin = true
                    let userUID = userInfoJson["uid"].int
                    let token = userInfoJson["token"].stringValue
                    print(userInfoJson)
                    LocalUserDefault.set(isLogin, forKey: "RunRRR_Login")
                    LocalUserDefault.set(userUID, forKey: "RunRRR_UID")
                    LocalUserDefault.set(token, forKey: "RunRRR_Token")
                    LocalUserDefault.synchronize()
                    let login = UIStoryboard(name: "Maps", bundle: nil).instantiateViewController(withIdentifier: "MapsViewController") as! MapsViewController
                    self.present(login, animated: true)
                    
                }else{
                    isLogin = false
                    LocalUserDefault.set(isLogin, forKey: "RunRRR_Login")
                    LocalUserDefault.synchronize()
                    self.showMessage(title: "Error", message:"Wrong password or the account doesn't exist")
                }
            }else{
                isLogin = false
                LocalUserDefault.set(isLogin, forKey: "RunRRR_Login")
                LocalUserDefault.synchronize()
                self.showMessage(title: "Error",message:"Time OUT")
            }
        }
        //Because the request process is async, and the built-in function is executed after the completion of the request.(That is a completionHandler)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
}


