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
        priorityLabel.textAlignment = NSTextAlignment(rawValue: 1)!
        priorityLabel.layer.borderWidth = CGFloat(2)
        priorityLabel.layer.borderColor = UIColor.black.cgColor
        priorityLabel.layer.cornerRadius = 0
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
        name.layer.borderColor = UIColor.black.cgColor
        name.layer.borderWidth = CGFloat(1)
        name.textAlignment = NSTextAlignment(rawValue: 1)!
        return name
    }()
    let missionTiming: UILabel = {
        let time = UILabel()
        time.text = "23:59"
        time.layer.borderWidth = CGFloat(1)
        return time
    }()
    let missionStatus: UIImageView = {
        let status = UIImageView()
        status.backgroundColor = UIColor.green
        status.layer.borderWidth = CGFloat(1)
        return status
    }()
    func setupView(){
        addSubview(missionPriorityThumbnail)
        //addSubview(seperateCell)
        addSubview(missionName)
        addSubview(missionTiming)
        addSubview(missionStatus)
        //Vertical
        addConstraintWithFormat(format: "V:|[v0]|", views: missionPriorityThumbnail)
        addConstraintWithFormat(format: "V:|[v0]|", views: missionName)
        addConstraintWithFormat(format: "V:|[v0]-0-[v1(50)]|", views: missionTiming, missionStatus)
        //Horizonal
        addConstraintWithFormat(format: "H:|[v0(80)]-0-[v1]-0-[v2(50)]|", views: missionPriorityThumbnail, missionName, missionTiming)
        //addConstraintWithFormat(format: "H:|[v0]|", views: seperateCell)
        addConstraint(NSLayoutConstraint(item: missionStatus, attribute: .left, relatedBy: .equal, toItem: missionName, attribute: .right, multiplier: 1, constant: 0))
        addConstraintWithFormat(format: "H:[v0(50)]", views: missionStatus)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
}

