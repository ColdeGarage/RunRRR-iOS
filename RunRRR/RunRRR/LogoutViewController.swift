//
//  LogoutViewController.swift
//  RunRRR
//
//  Created by Starla on 2017/4/1.
//  Copyright © 2017年 EEECamp. All rights reserved.
//
import Alamofire
import SwiftyJSON
import UIKit
import Foundation

class LogoutViewController: UIViewController  {
    var window: UIWindow?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    @IBAction func LogoutAction(_ sender: Any) {
        userLogout()
    }
    
    private func userLogout() {
        let LocalUserDefault = UserDefaults.standard
        LocalUserDefault.removeObject(forKey: "RunRRR_Login")
        LocalUserDefault.removeObject(forKey: "RunRRR_UID")
        LocalUserDefault.synchronize()
        
        
        let storyboard = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        self.present(storyboard, animated: true)
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
