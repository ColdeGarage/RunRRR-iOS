//
//  Login.swift
//  RunRRR
//
//  Created by Jacky Huang on 2017/3/5.
//  Copyright © 2017年 EEECamp. All rights reserved.
//

import UIKit

@IBDesignable class Login: UIButton {

    /*
    // Only override draw() if you perform custom drawing.a
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    @IBInspectable var borderWidth: CGFloat = 3
    override func draw(_ rect: CGRect){
        self.backgroundColor = .clear
        self.layer.cornerRadius = 5
        self.layer.borderWidth = CGFloat(borderWidth)
        self.layer.borderColor = UIColor.black.cgColor
    }
}
