//
//  TableViewCell.swift
//  RunRRR
//
//  Created by Jacky Huang on 2017/8/4.
//  Copyright © 2017年 EEECamp. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SnapKit

class DieTableViewCell: UITableViewCell {
    let smallCircle = UIImageView()
    let titleBarView = UIView()
    let titleLabel = UILabel()
    var vc: UIViewController?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupTitleBarView()
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupTitleBarView(){
        titleBarView.backgroundColor = UIColor(red: 244/255, green: 159/255, blue:54/255, alpha: 1)
        titleBarView.addSubview(smallCircle)
        titleBarView.addSubview(titleLabel)
        titleLabel.text = "Die"
        titleLabel.textColor = .white
        smallCircle.image = UIImage(named: "bar_circle_icon")
        smallCircle.contentMode = .scaleAspectFill
        let smallCircleSize = titleBarView.frame.height - 4
        
        smallCircle.snp.makeConstraints{(make) in
            make.left.equalTo(titleBarView).offset(10)
            make.width.equalTo(Int(smallCircleSize))
            make.top.equalTo(titleBarView).offset(2)
            make.height.equalTo(Int(smallCircleSize))
        }

        titleLabel.snp.makeConstraints{(make) in
            make.left.equalTo(smallCircle.snp.right).offset(10)
            make.right.equalTo(titleBarView).offset(-5)
            make.top.equalTo(titleBarView).offset(2)
            make.bottom.equalTo(titleBarView).offset(-2)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        contentView.endEditing(true)
        return false
    }
    
    func dismissKeyBoard() {
        contentView.endEditing(true)
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
        label.textColor = UIColor(red: 244/255, green: 159/255, blue:54/255, alpha: 1)
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    let hunterPWLabel : UILabel = {
        let label = UILabel()
        label.text = "Hunter's Password"
        label.textColor = UIColor(red: 244/255, green: 159/255, blue:54/255, alpha: 1)
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    let dieButton : UIButton = {
        let bt = UIButton(type: UIButtonType.system)
        bt.setTitle("BANG!", for: .normal)
        bt.setTitleColor(UIColor(red: 244/255, green: 159/255, blue:54/255, alpha: 1), for: .normal)
        bt.isEnabled = true
        bt.layer.borderWidth = 5
        bt.layer.cornerRadius = 5
        bt.layer.borderColor = UIColor(red: 244/255, green: 159/255, blue:54/255, alpha: 1).cgColor
        return bt
    }()
    
    @objc func goDie(_ sender: UIButton!){
        let UID = UserDefaults.standard.integer(forKey: "RunRRR_UID")
        let hunterID = self.hunterIDTextField.text!
        let hunterPW = self.hunterPWTextField.text!
        let pmForDie : Parameters = ["operator_uid":hunterID, "token":hunterPW, "uid":UID, "status":1]
        Alamofire.request("\(CONFIG.API_PREFIX.ROOT)/member/liveordie", method: .put, parameters: pmForDie).responseJSON{ response in
            print(response)
            switch(response.result){
                
            case .success(let value):
                let resJSON = JSON(value)
                if resJSON["brea"] == 0 {
                    UIApplication.shared.keyWindow?.rootViewController?.showAlertWindow(title:"Caution", message: "OK. You are death now.")
                }else {
                    UIApplication.shared.keyWindow?.rootViewController?.showAlertWindow(title:"Error", message: "Incorrect ID or PW!")
                }
            case .failure:
                UIApplication.shared.keyWindow?.rootViewController?.showAlertWindow(title:"Error", message: "Something went wrong.")
                break
            }
        }
    }
    
    private func setupView(){
        contentView.addSubview(titleBarView)
        contentView.addSubview(hunterIDLabel)
        contentView.addSubview(hunterPWLabel)
        contentView.addSubview(hunterIDTextField)
        contentView.addSubview(hunterPWTextField)
        contentView.addSubview(dieButton)
        
        titleBarView.snp.makeConstraints{(make) in
            make.left.right.equalTo(contentView)
            make.top.equalTo(contentView)
            make.height.equalTo(50)
        }
        
        hunterIDLabel.snp.makeConstraints{(make) in
            make.left.equalTo(contentView).offset(20)
            make.right.equalTo(contentView).offset(-20)
            make.top.equalTo(contentView).offset(75)
        }
        
        hunterIDTextField.snp.makeConstraints{(make) in
            make.left.equalTo(contentView).offset(50)
            make.right.equalTo(contentView).offset(-50)
            make.top.equalTo(hunterIDLabel.snp.bottom).offset(8)
            make.height.equalTo(30)
        }
        
        hunterPWLabel.snp.makeConstraints{(make) in
            make.left.equalTo(contentView).offset(20)
            make.right.equalTo(contentView).offset(-20)
            make.top.equalTo(hunterIDTextField).offset(15)
        }
        
        hunterPWTextField.snp.makeConstraints{(make) in
            make.left.equalTo(contentView).offset(50)
            make.right.equalTo(contentView).offset(-50)
            make.top.equalTo(hunterPWLabel.snp.bottom).offset(8)
            make.height.equalTo(30)
        }
        
        dieButton.snp.makeConstraints{(make) in
            make.left.equalTo(contentView).offset(80)
            make.right.equalTo(contentView).offset(-80)
            make.top.equalTo(hunterPWTextField.snp.bottom).offset(40)
            make.height.equalTo(40)
        }
        
        self.dieButton.addTarget(self, action: #selector(goDie(_:)), for: .touchUpInside)
    }
    
    func hideContent(_ isHidden:Bool){
        self.hunterIDLabel.isHidden = isHidden
        self.hunterPWLabel.isHidden = isHidden
        self.hunterIDTextField.isHidden = isHidden
        self.hunterPWTextField.isHidden = isHidden
        self.dieButton.isHidden = isHidden
    }
}

