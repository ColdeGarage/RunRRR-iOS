//
//  LogoutTableViewCell.swift
//  RunRRR
//
//  Created by Starla on 2017/8/4.
//  Copyright © 2017年 EEECamp. All rights reserved.
//

import UIKit
import SnapKit


class LogoutTableViewCell: UITableViewCell {
    
    let smallCircle = UIImageView()
    let titleBarView = UIView()
    let titleLabel = UILabel()
    var vc : UIViewController?
    
    let logoutButton : UIButton = {
        let bt = UIButton(type: UIButtonType.system)
        bt.setTitle("Logout", for: .normal)
        bt.setTitleColor(UIColor(red: 249/255, green: 51/255, blue:30/255, alpha: 1), for: .normal)
        bt.isEnabled = true
        bt.layer.borderWidth = 5
        bt.layer.cornerRadius = 5
        bt.layer.borderColor = UIColor(red: 249/255, green: 51/255, blue:30/255, alpha: 1).cgColor
        return bt
    }()
    let logoutLabel : UILabel = {
        let bt = UILabel()
        bt.text = "Sure to Logout?"
        bt.textColor = UIColor(red: 249/255, green: 51/255, blue:30/255, alpha: 1)
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
        contentView.snp.makeConstraints{(make) in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        contentView.addSubview(logoutButton)
        contentView.addSubview(logoutLabel)
        contentView.addSubview(titleBarView)
        
        titleBarView.snp.makeConstraints{(make) in
            make.left.right.equalTo(contentView)
            make.top.equalTo(contentView)
            make.height.equalTo(50)
        }
        
        logoutLabel.snp.makeConstraints{(make) in
            make.left.equalTo(contentView).offset(80)
            make.right.equalTo(contentView).offset(-80)
            make.top.equalTo(contentView).offset(100)
            make.height.equalTo(50)
        }
        
        logoutButton.snp.makeConstraints{(make) in
            make.left.equalTo(contentView).offset(80)
            make.right.equalTo(contentView).offset(-80)
            make.top.equalTo(logoutLabel.snp.bottom).offset(20)
            make.height.equalTo(50)
        }
        
        logoutButton.setTitle("Logout", for: .normal)
        self.logoutButton.addTarget(self, action: #selector(userLogout), for: .touchUpInside)
    }
    func setupTitleBarView(){
        titleBarView.backgroundColor = UIColor(red: 249/255, green: 51/255, blue:30/255, alpha: 1)
        titleBarView.addSubview(smallCircle)
        titleBarView.addSubview(titleLabel)
        
        titleLabel.text = "Logout"
        titleLabel.textColor = .white
        
        smallCircle.image = UIImage(named: "bar_circle_icon")
        smallCircle.contentMode = .scaleAspectFill
        
//        let smallCircleSize = titleBarView.frame.height - 4
        
        smallCircle.snp.makeConstraints{(make) in
            make.left.equalTo(titleBarView).offset(10)
            make.top.equalTo(titleBarView).offset(2)
            make.height.equalTo(titleBarView.snp.height).multipliedBy(0.8)
            make.width.equalTo(titleBarView.snp.height).multipliedBy(0.8)
        }
        
        titleLabel.snp.makeConstraints{(make) in
            make.left.equalTo(smallCircle.snp.right).offset(10)
            make.right.equalTo(titleBarView)
            make.top.equalTo(titleBarView).offset(2)
            make.bottom.equalTo(titleBarView).offset(-2)
        }
    }
    func hideContent(_ isHidden:Bool){
        self.logoutButton.isHidden = isHidden
    }
    
    @objc func userLogout() {
        let LocalUserDefault = UserDefaults.standard
        LocalUserDefault.removeObject(forKey: "RunRRR_Login")
        LocalUserDefault.removeObject(forKey: "RunRRR_UID")
        LocalUserDefault.synchronize()
        
        UIApplication.shared.keyWindow?.rootViewController?.present(LoginViewController(), animated: true, completion: nil)
    }
}
