//
//  ItemDetailView.swift
//  RunRRR
//
//  Created by Jacky Huang on 2017/4/23.
//  Copyright © 2017年 EEECamp. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SnapKit

protocol itemDetailViewProtocol {
    func itemUseButtonTapped()
}

class ItemDetailView: NSObject{
    let blackView = UIView()
    let detailWindow = ItemDetailWindow()
    var delegateViewController:MainViewController?
    var item : Item?
    var itemCount : Int = 0
    var worker: BagWorker?
    
    func showDetail(_ itemToDisplay: Item, itemCount: Int){
        //show detail view
        item = itemToDisplay
        self.itemCount = itemCount
        if let window = UIApplication.shared.keyWindow{
            blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
            detailWindow.backgroundColor = UIColor(red: 230/255, green: 230/255, blue:230/255, alpha: 1)
            window.addSubview(blackView)
            detailWindow.layer.cornerRadius = 10
            detailWindow.layer.masksToBounds = true
            blackView.frame = window.frame
            blackView.alpha = 0
            blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissDetail)))
            detailWindow.hideUseButton(self.item?.itemClass == .clue)
            
            detailWindow.itemNameLabel.text = itemToDisplay.name
            detailWindow.itemContentTextView.text = itemToDisplay.content
            detailWindow.itemCountLabel.text = self.itemCount.description

            detailWindow.itemUseButton.addTarget(self, action: #selector(useItem), for: .touchUpInside)
            detailWindow.itemCancelButton.addTarget(self, action: #selector(dismissDetail), for: .touchUpInside)
            window.addSubview(detailWindow)
            detailWindow.snp.makeConstraints{(make) in
                make.center.equalToSuperview()
                make.width.equalToSuperview().multipliedBy(0.8)
                make.height.equalToSuperview().multipliedBy(0.6)
            }
            detailWindow.setupWindow()
            UIView.animate(withDuration: 0.5, animations: {
                self.blackView.alpha = 1
                self.detailWindow.alpha = 1
            })
            
        }
    }
    
    @objc func dismissDetail(){
        UIView.animate(withDuration: 0.5, animations: {
            self.blackView.alpha = 0
            self.detailWindow.alpha = 0
        })
        
    }
    
    @objc func useItem(){
        let UID =  UserDefaults.standard.integer(forKey: "RunRRR_UID")
        let token = UserDefaults.standard.string(forKey: "RunRRR_Token")!
        
        let paraForDelete : Parameters = ["operator_uid":UID, "token":token, "pid":(self.item?.pid)!]
        Alamofire.request("\(CONFIG.API_PREFIX.ROOT)/pack/delete", method: HTTPMethod.delete, parameters: paraForDelete, encoding: URLEncoding.httpBody).responseJSON{ response in
            
            switch(response.result){
            case .success:
                self.worker!.refreshData()
            case .failure:
                print("Error!")
            }
        }
        DispatchQueue.main.async{
            self.dismissDetail()
        }
    }
}

class ItemDetailWindow : UIView{
    let itemNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Unknown_name"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18)
        label.backgroundColor = UIColor(red: 230/255, green: 230/255, blue:230/255, alpha: 1)
        return label
    }()
    let itemCountLabel: UILabel = {
        let label = UILabel()
        label.text = "1"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = UIColor.white
        label.backgroundColor = UIColor(red: 255/255, green: 41/255, blue:41/255, alpha: 1)
        label.layer.cornerRadius = 15
        label.layer.masksToBounds = true
        label.textAlignment = .center
        return label
    }()
    let itemUseButton: UIButton = {
        let button = UIButton()
        button.isEnabled = true
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.setTitleColor(UIColor(red: 255/255, green: 41/255, blue:41/255, alpha: 1), for: .normal)
        button.setTitle("USE", for: .normal)
        button.titleLabel?.textAlignment = NSTextAlignment.center
        return button
    }()
    let itemCancelButton: UIButton = {
        let button = UIButton()
        button.isEnabled = true
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.setTitleColor(UIColor.black, for: .normal)
        button.setTitle("CANCEL", for: .normal)
        button.titleLabel?.textAlignment = NSTextAlignment.center
        return button
    }()
    let itemContentTextView: UITextView = {
        let textView = UITextView()
        textView.text = "NO CONTENT!"
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.isUserInteractionEnabled = false
        textView.backgroundColor = UIColor(red: 230/255, green: 230/255, blue:230/255, alpha: 1)
        return textView
    }()
    /*let itemDetailWindowExitButton : UIButton = {
     let exitButton = UIButton()
     exitButton.titleLabel?.text = "X"
     return exitButton
     }()*/
    func setupWindow(){
        addSubview(itemNameLabel)
        addSubview(itemContentTextView)
        addSubview(itemUseButton)
        addSubview(itemCancelButton)
        addSubview(itemCountLabel)
        itemNameLabel.snp.makeConstraints{(make) in
            make.left.equalToSuperview().inset(20)
            make.right.equalToSuperview().inset(20)
            make.top.equalToSuperview().inset(8)
            make.height.equalTo(50)
        }
        itemContentTextView.snp.makeConstraints{(make) in
            make.top.equalTo(itemNameLabel.snp.bottom).offset(8)
            make.bottom.equalToSuperview().inset(10)
            make.left.equalToSuperview().inset(10)
            make.right.equalToSuperview().inset(10)
        }
        itemCountLabel.snp.makeConstraints{(make) in
            make.bottom.equalToSuperview().inset(15)
            make.height.equalTo(30)
            make.right.equalToSuperview().inset(20)
            make.width.equalTo(30)
        }
        itemUseButton.snp.makeConstraints{(make) in
            make.bottom.equalToSuperview().inset(15)
            make.height.equalTo(30)
            make.right.equalTo(itemCountLabel.snp.left)
            make.width.equalTo(50)
        }
        itemCancelButton.snp.makeConstraints{(make) in
            make.bottom.equalToSuperview().inset(15)
            make.height.equalTo(30)
            make.left.equalToSuperview().inset(20)
            make.width.equalTo(100)
        }
//        addConstraintWithFormat(format: "H:|-20-[v0]-20-|", views: itemNameLabel)
//        addConstraintWithFormat(format: "V:|-8-[v0(50)]-8-[v1]-10-|", views: itemNameLabel, itemContentTextView)
//        
//        addConstraintWithFormat(format: "V:[v0(30)]-15-|", views: itemCountLabel)
//        addConstraintWithFormat(format: "V:[v0(30)]-15-|", views: itemUseButton)
//        addConstraintWithFormat(format: "V:[v0(30)]-15-|", views: itemCancelButton)
//
//        addConstraintWithFormat(format: "H:|-20-[v0(100)]", views: itemCancelButton)
//        addConstraintWithFormat(format: "H:[v0(50)]-0-[v1(30)]-20-|", views: itemUseButton,itemCountLabel)
//        addConstraintWithFormat(format: "H:|-10-[v0]-10-|", views: itemContentTextView)
    }
    func hideUseButton(_ isHidden: Bool){
        self.itemUseButton.isHidden = isHidden
        self.itemCountLabel.isHidden = isHidden
    }
}

