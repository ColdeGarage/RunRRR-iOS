//
//  ItemDetailView.swift
//  RunRRR
//
//  Created by Jacky Huang on 2017/4/23.
//  Copyright © 2017年 EEECamp. All rights reserved.
//

import UIKit

class ItemDetailView: NSObject{
    let blackView = UIView()
    func showDetail(){
        //show detail view
        let detailWindow = ItemDetailWindow()
        if let window = UIApplication.shared.keyWindow{
            blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
            detailWindow.backgroundColor = UIColor.white
            window.addSubview(blackView)
            blackView.frame = window.frame
            blackView.alpha = 0
            
            window.addSubview(detailWindow)
            window.addConstraintWithFormat(format: "H:|-50-[v0]-50-|", views: detailWindow)
            window.addConstraintWithFormat(format: "V:|-80-[v0]-80-|", views: detailWindow)
            detailWindow.setupWindow()
            UIView.animate(withDuration: 0.5, animations: {
                self.blackView.alpha = 1
            })
            
        }
    }
    
    func dismissDetail(){
        UIView.animate(withDuration: 0.5, animations: {
            self.blackView.alpha = 0
        })
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
        button.titleLabel?.text = "Use it!"
        return button
    }()
    let itemDetailWindowExitButton : UIButton = {
        let exitButton = UIButton()
        exitButton.titleLabel?.text = "X"
        return exitButton
    }()
    func setupWindow(){
        addSubview(itemNameLabel)
        addSubview(itemUseButton)
        addSubview(itemDetailWindowExitButton)
        addConstraintWithFormat(format: "H:|-20-[v0]-20-|", views: itemNameLabel)
        addConstraintWithFormat(format: "V:|-8-[v0(50)]|", views: itemNameLabel)
    }
}
