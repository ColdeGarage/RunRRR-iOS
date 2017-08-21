//
//  BarcodeTableViewCell.swift
//  RunRRR
//
//  Created by Jacky Huang on 2017/8/3.
//  Copyright © 2017年 EEECamp. All rights reserved.
//

import UIKit

class BarcodeTableViewCell: UITableViewCell {
    let smallCircle = UIImageView()
    let titleBarView = UIView()
    let titleLabel = UILabel()
    let userID = UserDefaults.standard.integer(forKey: "RunRRR_UID")
    let barcodeImageView = UIImageView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupTitleBarView()
        setupView()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func setupView(){
        contentView.addSubview(titleBarView)
        contentView.addSubview(barcodeImageView)
        contentView.addConstraintWithFormat(format: "H:|[v0]|", views: titleBarView)
        contentView.addConstraintWithFormat(format: "V:|[v0(50)]", views: titleBarView)
        contentView.addConstraintWithFormat(format: "H:|-20-[v0]-20-|", views: barcodeImageView)
        contentView.addConstraintWithFormat(format: "V:[v0]-100-[v1(100)]", views: titleBarView,barcodeImageView)
        
        barcodeImageView.image = encodeImageFromUID(userID)
    }
    func setupTitleBarView(){
        titleBarView.backgroundColor = UIColor(red: 72/255, green: 218/255, blue: 186/255, alpha: 1)
        titleBarView.addSubview(smallCircle)
        titleBarView.addSubview(titleLabel)
        titleLabel.text = "Barcode"
        titleLabel.textColor = .white
        smallCircle.image = UIImage(named: "bar_circle_icon")
        smallCircle.contentMode = .scaleAspectFill
        
        let smallCircleSize = titleBarView.frame.height - 4
        titleBarView.addConstraintWithFormat(format: "H:|-10-[v0(\(smallCircleSize))]-10-[v1]-5-|", views: smallCircle, titleLabel)
        titleBarView.addConstraintWithFormat(format: "V:|-2-[v0(\(smallCircleSize))]-2-|", views: smallCircle)
        titleBarView.addConstraintWithFormat(format: "V:|-2-[v0(\(smallCircleSize))]-2-|", views: titleLabel)
    }
    func encodeImageFromUID(_ uid: Int) -> UIImage? {
        let uidString = String(uid)
        let data = uidString.data(using: .ascii)
        let filter = CIFilter(name: "CICode128BarcodeGenerator")
        filter?.setValue(data, forKey: "inputMessage")
        
        return UIImage(ciImage: (filter?.outputImage)!)
    }
    func hideContent(_ isHidden:Bool){
        self.barcodeImageView.isHidden = isHidden
    }
}
