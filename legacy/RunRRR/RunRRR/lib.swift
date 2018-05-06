//
//  lib.swift
//  RunRRR
//
//  Created by Jacky Huang on 2017/4/26.
//  Copyright © 2017年 EEECamp. All rights reserved.
//

import UIKit

extension UIView{
    func addConstraintWithFormat(format: String, views:UIView...){
        var viewsDictionary = [String: UIView]()
        for(index, view) in views.enumerated(){
            let key = "v\(index)"
            view.translatesAutoresizingMaskIntoConstraints = false
            viewsDictionary[key] = view
        }
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
    }
    
    
}

