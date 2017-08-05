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

protocol itemDetailViewProtocol {
    func itemUseButtonTapped()
}

class ItemDetailView: NSObject{
    let blackView = UIView()
    let detailWindow = ItemDetailWindow()
    var delegateViewController:BagCollectionViewController?
    var item : Item?
    var itemCount : Int = 0
    
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
            //detailWindow.itemCountLabel.text = String(self.bag[indexPath.item-1].count)
            
            detailWindow.itemUseButton.addTarget(self, action: #selector(useItem), for: .touchUpInside)
            detailWindow.itemCancelButton.addTarget(self, action: #selector(dismissDetail), for: .touchUpInside)
            window.addSubview(detailWindow)
            window.addConstraintWithFormat(format: "H:|-\(blackView.frame.width/10)-[v0]-\(blackView.frame.width/10)-|", views: detailWindow)
            window.addConstraintWithFormat(format: "V:|-\(blackView.frame.height/5)-[v0]-\(blackView.frame.height/5)-|", views: detailWindow)
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
    
    func useItem(){
        let UID =  UserDefaults.standard.integer(forKey: "RunRRR_UID")
        let token = UserDefaults.standard.string(forKey: "RunRRR_Token")!
        
        let paraForDelete : Parameters = ["operator_uid":UID, "token":token, "pid":(self.item?.pid)!]
        print(paraForDelete.description)
        Alamofire.request("\(API_URL)/pack/delete", method: HTTPMethod.delete, parameters: paraForDelete, encoding: URLEncoding.httpBody).responseJSON{ response in
            print(response)
            
            switch(response.result){
            case .success:
                _ = self.delegateViewController?.packs.popLast()
            case .failure:
                print("Error!")
            }
        }
        DispatchQueue.main.async{
            self.dismissDetail()
            self.delegateViewController?.fetchPacks()
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
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        label.textAlignment = .center
        return label
    }()
    let itemUseButton: UIButton = {
        let button = UIButton()
        button.isEnabled = true
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.setTitleColor(UIColor(red: 255/255, green: 41/255, blue:41/255, alpha: 1), for: .normal)
        button.setTitle("USE", for: .normal)
        button.titleLabel?.textAlignment = NSTextAlignment.center
        return button
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
        //addSubview(itemDetailWindowExitButton)
        
        
        addConstraintWithFormat(format: "H:|-20-[v0]-20-|", views: itemNameLabel)
        addConstraintWithFormat(format: "V:|-8-[v0(50)]-8-[v1]-10-|", views: itemNameLabel, itemContentTextView)
        
        addConstraintWithFormat(format: "V:[v0(20)]-15-|", views: itemCountLabel)
        addConstraintWithFormat(format: "V:[v0(20)]-15-|", views: itemUseButton)
        addConstraintWithFormat(format: "V:[v0(20)]-15-|", views: itemCancelButton)
        
        addConstraintWithFormat(format: "H:|-20-[v0(60)]", views: itemCancelButton)
        addConstraintWithFormat(format: "H:[v0(40)]-0-[v1(30)]-20-|", views: itemUseButton,itemCountLabel)
        addConstraintWithFormat(format: "H:|-10-[v0]-10-|", views: itemContentTextView)
    }
    func hideUseButton(_ isHidden: Bool){
        self.itemUseButton.isHidden = isHidden
        self.itemCountLabel.isHidden = isHidden
    }
}
