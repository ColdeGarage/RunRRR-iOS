//
//  LogoutTableViewCell.swift
//  RunRRR
//
//  Created by Starla on 2017/8/4.
//  Copyright © 2017年 EEECamp. All rights reserved.
//

import UIKit

class LogoutTableViewCell: UITableViewCell {
    
    let smallCircle = UIImageView()
    let titleBarView = UIView()
    let titleLabel = UILabel()
    var vc : UIViewController?
    
    let logoutButton : UIButton = {
        let bt = UIButton(type: UIButtonType.system)
        bt.setTitle("SOS", for: .normal)
        bt.setTitleColor(UIColor(red: 80/255, green: 88/255, blue:103/255, alpha: 1), for: .normal)
        bt.isEnabled = true
        bt.layer.borderWidth = 5
        bt.layer.cornerRadius = 5
        bt.layer.borderColor = UIColor(red: 80/255, green: 88/255, blue:103/255, alpha: 1).cgColor
        return bt
    }()
    let logoutLabel : UILabel = {
        let bt = UILabel()
        bt.text = "Sure to Logout?"
        bt.textColor = UIColor(red: 80/255, green: 88/255, blue:103/255, alpha: 1)
        bt.textAlignment = .center
        return bt
    }()
    
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
    
    func setupView(){
        contentView.addSubview(logoutButton)
        contentView.addSubview(logoutLabel)
        contentView.addSubview(titleBarView)
        contentView.addConstraintWithFormat(format: "H:|[v0]|", views: titleBarView)
        contentView.addConstraintWithFormat(format: "V:|[v0(50)]", views: titleBarView)
        contentView.addConstraintWithFormat(format: "V:|-100-[v0(50)]-20-[v1(50)]", views: logoutLabel,logoutButton)
        contentView.addConstraintWithFormat(format: "H:|-80-[v0]-80-|", views: logoutButton)
        contentView.addConstraintWithFormat(format: "H:|-80-[v0]-80-|", views: logoutLabel)
//        contentView.addConstraint(NSLayoutConstraint(item: logoutButton, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
//        contentView.addConstraint(NSLayoutConstraint(item: logoutButton, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        logoutButton.setTitle("Logout", for: .normal)
        logoutButton.setTitleColor(.black, for: .normal)
        self.logoutButton.addTarget(self, action: #selector(userLogout), for: .touchUpInside)
    }
    func setupTitleBarView(){
        titleBarView.backgroundColor = UIColor(red: 80/255, green: 88/255, blue:103/255, alpha: 1)
        titleBarView.addSubview(smallCircle)
        titleBarView.addSubview(titleLabel)
        
        titleLabel.text = "Logout"
        titleLabel.textColor = .white
        
        smallCircle.image = UIImage(named: "bar_circle_icon")
        smallCircle.contentMode = .scaleAspectFill
        
        let smallCircleSize = titleBarView.frame.height - 4
        titleBarView.addConstraintWithFormat(format: "H:|-10-[v0(\(smallCircleSize))]-10-[v1]-5-|", views: smallCircle, titleLabel)
        titleBarView.addConstraintWithFormat(format: "V:|-2-[v0(\(smallCircleSize))]-2-|", views: smallCircle)
        titleBarView.addConstraintWithFormat(format: "V:|-2-[v0(\(smallCircleSize))]-2-|", views: titleLabel)
        
        
    }
    func hideContent(_ isHidden:Bool){
        self.logoutButton.isHidden = isHidden
    }
    
    func userLogout() {
        let LocalUserDefault = UserDefaults.standard
        LocalUserDefault.removeObject(forKey: "RunRRR_Login")
        LocalUserDefault.removeObject(forKey: "RunRRR_UID")
        LocalUserDefault.synchronize()
        
        
        let storyboard = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        vc?.present(storyboard, animated: true)
    }
}
