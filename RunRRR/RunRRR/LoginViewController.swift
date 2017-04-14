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

    // MARK: Outlet
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var accountTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initLoginAppearance()
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
            showMessage(message: "Please enter your account.")
        }else if(userPassword.isEmpty){
            showMessage(message: "Please enter your password.")
        }else{
            // Auth
            userLogin(account: userAccount, password: userPassword)
        }
        //Checking both textfields are not emptys

    }
    
    
    func showMessage(message: String){
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    private func initLoginAppearance(){
        loginButton.layer.cornerRadius = 5
        loginButton.layer.borderWidth = CGFloat(3)
        loginButton.layer.borderColor = UIColor.black.cgColor
        
        accountTextField.layer.cornerRadius = 5
        accountTextField.layer.borderWidth = CGFloat(1)
        accountTextField.layer.borderColor = UIColor.black.cgColor
        
        passwordTextField.layer.cornerRadius = 5
        passwordTextField.layer.borderWidth = CGFloat(1)
        passwordTextField.layer.borderColor = UIColor.black.cgColor
    }
    
    private func userLogin(account: String, password: String) -> Void{
        /*let loginURL="file:///Users/jackyhuang/Desktop/login.json"*/
        let loginInfo : [String:Any] = ["email":account, "password":password]
        
        var isLogin: Bool = false  //Check login state.
        let LocalUserDefault = UserDefaults.standard
        Alamofire.request("http://coldegarage.tech:8081/api/v1/member/login", method: .post, parameters: loginInfo).responseJSON{ response in
            if ((response.result.value) != nil) {
                let userInfoJson = JSON(response.result.value!)
                if(!userInfoJson["payload"]["correct"].boolValue){
                    isLogin = true
                    let userUID = userInfoJson["uid"].int
                    print(userInfoJson)
                    LocalUserDefault.set(isLogin, forKey: "RunRRR_Login")
                    LocalUserDefault.set(userUID, forKey: "RunRRR_UID")
                    LocalUserDefault.synchronize()
                    let login = UIStoryboard(name: "Maps", bundle: nil).instantiateViewController(withIdentifier: "MapsViewController") as! MapsViewController
                    self.present(login, animated: true)
                    
                }else{
                    isLogin = false
                    LocalUserDefault.set(isLogin, forKey: "RunRRR_Login")
                    LocalUserDefault.synchronize()
                    self.showMessage(message:"Wrong password or the account doesn't exist")
                }
            }else{
                isLogin = false
                LocalUserDefault.set(isLogin, forKey: "RunRRR_Login")
                LocalUserDefault.synchronize()
                self.showMessage(message:"Time OUT")
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
