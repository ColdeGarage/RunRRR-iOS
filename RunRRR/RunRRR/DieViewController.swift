//
//  DieViewController.swift
//  RunRRR
//
//  Created by Jacky Huang on 2017/7/8.
//  Copyright © 2017年 EEECamp. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON


class DieViewController: UIViewController, UITextFieldDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapDismissKeyBoard : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DieViewController.dismissKeyBoard))
        self.hunterIDTextField.delegate = self
        self.hunterPWTextField.delegate = self
        setupView()
        view.addGestureRecognizer(tapDismissKeyBoard)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func dismissKeyBoard() {
        view.endEditing(true)
    }
    
    let hunterIDTextField : UITextField = {
        let tf = UITextField()
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor.lightGray.cgColor
        tf.layer.cornerRadius = 3
        tf.keyboardType = .decimalPad
        tf.returnKeyType = .continue
        return tf
    }()
    let hunterPWTextField : UITextField = {
        let tf = UITextField()
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor.lightGray.cgColor
        tf.layer.cornerRadius = 3
        tf.isSecureTextEntry = true
        tf.returnKeyType = .done
        return tf
    }()
    let hunterIDLabel : UILabel = {
        let label = UILabel()
        label.text = "Hunter's ID"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    let hunterPWLabel : UILabel = {
        let label = UILabel()
        label.text = "Hunter's Password"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    let dieButton : UIButton = {
        let bt = UIButton(type: UIButtonType.system)
        bt.setTitle("死吧", for: .normal)
        bt.isEnabled = true
        bt.layer.borderWidth = 2
        return bt
    }()
    
    func goDie(_ sender: UIButton!){
        let UID = UserDefaults.standard.integer(forKey: "RunRRR_UID")
        let hunterID = self.hunterIDTextField.text!
        let hunterPW = self.hunterPWTextField.text!
        let pmForDie : Parameters = ["operator_uid":hunterID, "token":hunterPW, "uid":UID, "status":0]
        Alamofire.request("\(API_URL)/member/liveordie", method: .put, parameters: pmForDie).responseJSON{ response in
            print(response)
            switch(response.result){
                
            case .success(let value):
                let resJSON = JSON(value)
                if resJSON["brea"] == 0 {
                    self.showMessage(title:"Caution", message: "OK. You are death now.")
                }else {
                    self.showMessage(title:"Error", message: "Incorrect ID or PW!")
                }
            case .failure:
                self.showMessage(title:"Error", message: "Something went wrong.")
            }
        }
    }
    
    private func setupView(){
        view.addSubview(hunterIDLabel)
        view.addSubview(hunterPWLabel)
        view.addSubview(hunterIDTextField)
        view.addSubview(hunterPWTextField)
        view.addSubview(dieButton)
        view.addConstraintWithFormat(format: "H:|-20-[v0]-20-|", views: hunterIDLabel)
        view.addConstraintWithFormat(format: "H:|-20-[v0]-20-|", views: hunterPWLabel)
        view.addConstraintWithFormat(format: "H:|-50-[v0]-50-|", views: hunterIDTextField)
        view.addConstraintWithFormat(format: "H:|-50-[v0]-50-|", views: hunterPWTextField)
        view.addConstraintWithFormat(format: "H:|-80-[v0]-80-|", views: dieButton)
        let formatForVertical = "V:|-\(view.frame.height/4)-[v0]-8-[v1(30)]-15-[v2]-8-[v3(30)]-40-[v4]" as String
        view.addConstraintWithFormat(format: formatForVertical, views: hunterIDLabel, hunterIDTextField, hunterPWLabel, hunterPWTextField, dieButton)
        self.dieButton.addTarget(self, action: #selector(goDie(_:)), for: .touchUpInside)
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
