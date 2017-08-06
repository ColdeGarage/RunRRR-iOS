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
        titleBarView.addConstraintWithFormat(format: "H:|-10-[v0(\(smallCircleSize))]-10-[v1]-5-|", views: smallCircle, titleLabel)
        titleBarView.addConstraintWithFormat(format: "V:|-2-[v0(\(smallCircleSize))]-2-|", views: smallCircle)
        titleBarView.addConstraintWithFormat(format: "V:|-2-[v0(\(smallCircleSize))]-2-|", views: titleLabel)
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
    
    func goDie(_ sender: UIButton!){
        let UID = UserDefaults.standard.integer(forKey: "RunRRR_UID")
        let hunterID = self.hunterIDTextField.text!
        let hunterPW = self.hunterPWTextField.text!
        let pmForDie : Parameters = ["operator_uid":hunterID, "token":hunterPW, "uid":UID, "status":1]
        Alamofire.request("\(API_URL)/member/liveordie", method: .put, parameters: pmForDie).responseJSON{ response in
            print(response)
            switch(response.result){
                
            case .success(let value):
                let resJSON = JSON(value)
                if resJSON["brea"] == 0 {
                    self.vc?.showMessage(title:"Caution", message: "OK. You are death now.")
                }else {
                    self.vc?.showMessage(title:"Error", message: "Incorrect ID or PW!")
                }
            case .failure:
                self.vc?.showMessage(title:"Error", message: "Something went wrong.")
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
        contentView.addConstraintWithFormat(format: "H:|[v0]|", views: titleBarView)
        contentView.addConstraintWithFormat(format: "V:|[v0(50)]", views: titleBarView)
        contentView.addConstraintWithFormat(format: "H:|-20-[v0]-20-|", views: hunterIDLabel)
        contentView.addConstraintWithFormat(format: "H:|-20-[v0]-20-|", views: hunterPWLabel)
        contentView.addConstraintWithFormat(format: "H:|-50-[v0]-50-|", views: hunterIDTextField)
        contentView.addConstraintWithFormat(format: "H:|-50-[v0]-50-|", views: hunterPWTextField)
        contentView.addConstraintWithFormat(format: "H:|-80-[v0]-80-|", views: dieButton)
        let formatForVertical = "V:|-75-[v0]-8-[v1(30)]-15-[v2]-8-[v3(30)]-40-[v4]" as String
        contentView.addConstraintWithFormat(format: formatForVertical, views: hunterIDLabel, hunterIDTextField, hunterPWLabel, hunterPWTextField, dieButton)
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
//self.hunterIDTextField.delegate = self.contentView
//self.hunterPWTextField.delegate = self.contentView
