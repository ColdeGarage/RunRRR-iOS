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
    let UID = UserDefaults.standard.integer(forKey: "RunRRR_UID")
    let token = UserDefaults.standard.string(forKey: "RunRRR_token")
    func showDetail(_ itemToDisplay: Item){
        //show detail view
        item = itemToDisplay
        if let window = UIApplication.shared.keyWindow{
            blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
            detailWindow.backgroundColor = UIColor.white
            window.addSubview(blackView)
            blackView.frame = window.frame
            blackView.alpha = 0
            blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissDetail)))
            detailWindow.itemNameLabel.text = itemToDisplay.name
            detailWindow.itemContentTextView.text = itemToDisplay.content
            detailWindow.itemUseButton.addTarget(self, action: #selector(useItem), for: .touchUpInside)
            window.addSubview(detailWindow)
            window.addConstraintWithFormat(format: "H:|-50-[v0]-50-|", views: detailWindow)
            window.addConstraintWithFormat(format: "V:|-80-[v0]-80-|", views: detailWindow)
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
        let paraForDelete = ["operator_uid":self.UID, "pid":self.item?.pid as Any] as Parameters
        Alamofire.request("\(API_URL)/pack/delete", method: .delete, parameters: paraForDelete).responseJSON{ response in
            switch(response.result){
            case .success:
                _ = BagCollectionViewController().packs.popLast()
            case .failure:
                print("Error!")
            }
        }
        DispatchQueue.main.async{
            self.dismissDetail()
            _ = self.delegateViewController?.packs.dropLast()
            self.delegateViewController?.collectionView?.reloadData()
        }
    }
}

class ItemDetailWindow : UIView{
    let itemNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 36)
        label.text = "Unknown_name"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 24)
        return label
    }()
    let itemUseButton: UIButton = {
        let button = UIButton()
        button.isEnabled = true
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.setTitleColor(UIColor.black, for: .normal)
        button.setTitle("USE", for: .normal)
        return button
    }()
    let itemContentTextView: UITextView = {
        let textView = UITextView()
        textView.text = "NO CONTENT!"
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.isUserInteractionEnabled = false
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
        //addSubview(itemDetailWindowExitButton)
        
        
        addConstraintWithFormat(format: "H:|-20-[v0]-20-|", views: itemNameLabel)
        addConstraintWithFormat(format: "V:|-8-[v0(50)]-8-[v1]-10-|", views: itemNameLabel, itemContentTextView)
        addConstraintWithFormat(format: "H:[v0(60)]-10-|", views: itemUseButton)
        addConstraintWithFormat(format: "V:[v0(60)]-10-|", views: itemUseButton)
        addConstraintWithFormat(format: "H:|-10-[v0]-10-|", views: itemContentTextView)
    }
}
