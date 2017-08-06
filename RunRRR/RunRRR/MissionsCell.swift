//
//  MissionsCell.swift
//  RunRRR
//
//  Created by Jacky Huang on 2017/4/4.
//  Copyright © 2017年 EEECamp. All rights reserved.
//

import UIKit


@IBDesignable class MissionsCell: UICollectionViewCell{
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    let missionPriorityThumbnail: UILabel = {
        let priorityLabel = UILabel()
        
        priorityLabel.text = "主"
        priorityLabel.font = UIFont.systemFont(ofSize: 36)
        priorityLabel.textColor = UIColor.white
        priorityLabel.textAlignment = NSTextAlignment(rawValue: 1)!
        priorityLabel.backgroundColor = UIColor.white
        priorityLabel.layer.borderWidth = CGFloat(0)
        priorityLabel.layer.borderColor = UIColor.white.cgColor
        priorityLabel.layer.cornerRadius = 35
        priorityLabel.layer.masksToBounds = true
        
        return priorityLabel
    }()
    let seperateCell: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.blue
        return view
    }()
    let missionName: UILabel = {
        let name = UILabel()
        name.text = "Example Mission"
        name.textColor = UIColor.white
        name.layer.borderColor = UIColor.white.cgColor
        name.layer.borderWidth = CGFloat(0)
        name.textAlignment = NSTextAlignment(rawValue: 1)!
        return name
    }()
    let missionTiming: UILabel = {
        let time = UILabel()
        time.text = "23:59"
        time.textAlignment = NSTextAlignment.center
        time.textColor = UIColor.darkGray
        time.layer.borderWidth = CGFloat(0)
        time.layer.borderColor = UIColor.white.cgColor
        time.layer.cornerRadius = 5
        time.layer.masksToBounds = true
        return time
    }()
    let missionStatus: UIImageView = {
        let status = UIImageView()
        
        status.layer.borderWidth = CGFloat(0)
        status.layer.borderColor = UIColor.white.cgColor
        status.layer.cornerRadius = 15
        status.layer.masksToBounds = true
        
        return status
    }()
    func setupView(){
        addSubview(missionPriorityThumbnail)
        addSubview(missionName)
        addSubview(missionTiming)
        addSubview(missionStatus)
        
        //Vertical
        addConstraintWithFormat(format: "V:[v0(70)]", views: missionPriorityThumbnail)
        addConstraint(NSLayoutConstraint(item: missionPriorityThumbnail, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        addConstraintWithFormat(format: "V:|[v0]|", views: missionName)
        addConstraintWithFormat(format: "V:[v0(30)]-5-|", views: missionTiming)
        addConstraintWithFormat(format: "V:[v0(30)]-5-|", views: missionStatus)
        
        //Horizonal
        addConstraintWithFormat(format: "H:|-5-[v0(70)]-5-[v1]-5-[v2(50)]-5-|", views: missionPriorityThumbnail, missionName, missionTiming)
        addConstraintWithFormat(format: "H:|-50-[v0(30)]", views: missionStatus)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
}

