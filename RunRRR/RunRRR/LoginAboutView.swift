//
//  LoginAboutView.swift
//  RunRRR
//
//  Created by Starla on 2017/8/6.
//  Copyright © 2017年 EEECamp. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON



class LoginAboutView: NSObject{
    let blackView = UIView()
    let detailWindow = LoginAboutWindow()
    var delegateViewController: LoginViewController?
  
    
    func showDetail(){
        if let window = UIApplication.shared.keyWindow{
            blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
            detailWindow.backgroundColor = UIColor(red: 183/255, green: 183/255, blue:183/255, alpha: 1)
            window.addSubview(blackView)
            detailWindow.layer.cornerRadius = 10
            detailWindow.layer.masksToBounds = true
            blackView.frame = window.frame
            blackView.alpha = 0
            blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissDetail)))
            
            detailWindow.itemNameLabel.text = "ABOUT US"
            detailWindow.itemContentTextView.text = "    Hi, 我們是ColdeGarage, 位於資電館822屬於清大電機的Maker Space\n\n    我們致力於提倡電機系的自造風氣，有想做的東西嗎?來就對了。\n\n    至於這個APP，是由一位上古英文營神獸大佬所突然靈光乍現，對營隊活動有所不滿，於是他施展了封印黑魔法召喚一群沒有能力的召喚師。但是這群召喚師們非常爭氣，努力向上，最後完成了這個APP，也改善了這個營隊一開始不方便的地方。\n\n    如果你對任何活動有不滿或有意見，也歡迎模仿上古英文營神獸大佬來組建自己的團隊，為自己的系上或活動來努力吧！加油～各位年輕的召喚師們！未來是你們的！\n\n>>開發者們的一句話：\n\n洪繹峻：宣傑徵女友，cos魯到朽，快逃Rrr，一起變朋友！\n\n楊淳佑：爆肝人生。\n\n黃宣傑(Jacky)：被21囉 也要繼續打扣 希望能提前竣工ˊˋ\n\n謝承翰(QMo)：好想出去玩！\n\n陳玉璇：我會魯4/3輩子QQ\n\n曾筱茵：打完扣就可以睡了嗎\n陳邦亢：一時衝動就入了這個坑，超嗨der！\n\n楊靜璇：想不開就是成功的開始ㄎㄎ\n\n魏嘉緯：抓神獸囉！"
            
            detailWindow.itemCancelButton.addTarget(self, action: #selector(dismissDetail), for: .touchUpInside)
            window.addSubview(detailWindow)
            window.addConstraintWithFormat(format: "H:|-\(blackView.frame.width/10)-[v0]-\(blackView.frame.width/10)-|", views: detailWindow)
            window.addConstraintWithFormat(format: "V:|-\(blackView.frame.height/10)-[v0]-\(blackView.frame.height/10)-|", views: detailWindow)
            detailWindow.setupWindow()
            UIView.animate(withDuration: 0.5, animations: {
                self.blackView.alpha = 1
                self.detailWindow.alpha = 1
            })
            
        }
    }
    
    func dismissDetail(){
        UIView.animate(withDuration: 0.5, animations: {
            self.blackView.alpha = 0
            self.detailWindow.alpha = 0
        })
        
    }
    
}

class LoginAboutWindow : UIView{
    let itemNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Unknown_name"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18)
        label.backgroundColor = UIColor(red: 183/255, green: 183/255, blue:183/255, alpha: 1)
        return label
    }()
        let itemCancelButton: UIButton = {
        let button = UIButton()
        button.isEnabled = true
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.setTitleColor(UIColor.black, for: .normal)
        button.setTitle("CANCEL", for: .normal)
        button.titleLabel?.textAlignment = NSTextAlignment.center
        return button
    }()
    let itemContentTextView: UITextView = {
        let textView = UITextView()
        textView.text = "NO CONTENT!"
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.isEditable = false
        textView.backgroundColor = UIColor(red: 183/255, green: 183/255, blue:183/255, alpha: 1)
        return textView
    }()
    
    func setupWindow(){
        
        addSubview(itemNameLabel)
        addSubview(itemContentTextView)
        addSubview(itemCancelButton)
        
        addConstraintWithFormat(format: "H:|-20-[v0]-20-|", views: itemNameLabel)
        addConstraintWithFormat(format: "V:|-8-[v0(50)]-8-[v1]-25-[v2(20)]-15-|", views: itemNameLabel, itemContentTextView,itemCancelButton)
        
        addConstraintWithFormat(format: "H:|-20-[v0(60)]", views: itemCancelButton)
        addConstraintWithFormat(format: "H:|-10-[v0]-10-|", views: itemContentTextView)
    }
    
}
