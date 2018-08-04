//
//  BarcodeTableViewCell.swift
//  RunRRR
//
//  Created by Jacky Huang on 2017/8/3.
//  Copyright © 2017年 EEECamp. All rights reserved.
//

import UIKit
import SnapKit

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
        
        titleBarView.snp.makeConstraints{(make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(50)
        }
        
        barcodeImageView.snp.makeConstraints{(make) in
            make.left.equalTo(contentView).offset(20)
            make.right.equalTo(contentView).offset(-20)
            make.top.equalTo(titleLabel.snp.bottom).offset(100)
            make.height.equalTo(100)
        }
        
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
        
        smallCircle.snp.makeConstraints{(make) in
            make.left.equalTo(titleBarView).offset(10)
            make.width.equalTo(Int(smallCircleSize))
            make.top.equalTo(titleBarView).offset(2)
            make.height.equalTo(Int(smallCircleSize))
        }
        
        titleLabel.snp.makeConstraints{(make) in
            make.left.equalTo(smallCircle.snp.right).offset(10)
            make.right.equalTo(titleBarView).offset(-5)
            make.top.equalTo(titleBarView).offset(2)
            make.bottom.equalTo(titleBarView).offset(-2)
        }
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
