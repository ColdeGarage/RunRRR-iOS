//
//  LoginAPI.swift
//  RunRRR 2.0
//
//  Created by Jacky Huang on 2018/5/12.
//  Copyright © 2018年 ColdeGarage. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class LoginAPI{
    var userID: String?
    var userPwd: String?
    var token: String?
    
    init(_ email: String, _ password: String) {
        self.userID = email
        self.userPwd = password
    }
    
    func checkAndLogin(_ resultHandler: @escaping (_ result: LoginResult) -> ()){
        if (self.userID?.isEmpty)! {
            resultHandler(.emptyEmail)
        }
        else if (self.userPwd?.isEmpty)! {
            resultHandler(.emptyPwd)
        }
        else {
            self.callAPI(resultHandler)
        }
    }
    
    private func callAPI(_ resultHandler: @escaping (_ result: LoginResult) -> ()){
        let data: [String : Any] = ["email": self.userID!, "password": self.userPwd!]
        Alamofire.request((CONFIG.API_PREFIX.ROOT + "member/login"), method: .post, parameters: data).responseJSON{ response in
            if (response.result.value == nil){
                resultHandler(.error)
                return
            }
            let json = JSON(response.result.value!)
            print(json)
            if (!json["payload"]["correct"].boolValue){
                let uid = json["uid"].int
                let token = json["token"].stringValue
                let localUserDefault = UserDefaults.standard

                localUserDefault.set(true, forKey: "RunRRR_Login")
                localUserDefault.set(uid, forKey: "RunRRR_UID")
                localUserDefault.set(token, forKey: "RunRRR_Token")
                localUserDefault.synchronize()
                
                resultHandler(.succeed)
            }
            else {
                resultHandler(.wrongEmailOrPwd)
            }
        }
    }
}


enum LoginResult {
    case succeed
    case emptyPwd
    case emptyEmail
    case wrongEmailOrPwd
    case error
}
