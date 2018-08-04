//
//  AboutUsTableViewCell.swift
//  RunRRR
//
//  Created by Yi-Chun on 2017/8/4.
//  Copyright © 2017年 EEECamp. All rights reserved.
//

import UIKit
import SnapKit

class AboutUsTableViewCell: UITableViewCell {
    
    let smallCircle = UIImageView()
    let titleBarView = UIView()
    let titleLabel = UILabel()
    let aboutUsTextView = UITextView()
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        setupTitleBarView()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupView(){
        contentView.snp.makeConstraints{(make) in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        
        contentView.addSubview(aboutUsTextView)
        contentView.addSubview(titleBarView)
        
        titleBarView.snp.makeConstraints{(make) in
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.top.equalTo(0)
            make.height.equalTo(50)
        }
        aboutUsTextView.snp.makeConstraints{(make) in
            make.left.equalTo(contentView).offset(20)
            make.right.equalTo(contentView).offset(-20)
            make.top.equalTo(titleBarView.snp.bottom).offset(25)
            make.height.equalTo(200)
        }
        aboutUsTextView.text = "    Hi, 我們是ColdeGarage, 位於資電館822屬於清大電機的Maker Space\n\n    我們致力於提倡電機系的自造風氣，有想做的東西嗎?來就對了。\n\n    至於這個APP，是由一位上古英文營神獸大佬所突然靈光乍現，對營隊活動有所不滿，於是他施展了封印黑魔法召喚一群沒有能力的召喚師。但是這群召喚師們非常爭氣，努力向上，最後完成了這個APP，也改善了這個營隊一開始不方便的地方。\n\n    如果你對任何活動有不滿或有意見，也歡迎模仿上古英文營神獸大佬來組建自己的團隊，為自己的系上或活動來努力吧！加油～各位年輕的召喚師們！未來是你們的！\n\n>>開發者們的一句話：\n\n洪繹峻：宣傑徵女友，cos魯到朽，快逃Rrr，一起變朋友！\n\n楊淳佑：爆肝人生。\n\n黃宣傑(Jacky)：被21囉 也要繼續打扣 希望能提前竣工ˊˋ\n\n謝承翰(QMo)：好想出去玩！\n\n陳玉璇：我會魯4/3輩子QQ\n\n曾筱茵：打完扣就可以睡了嗎\n陳邦亢：一時衝動就入了這個坑，超嗨der！\n\n楊靜璇：想不開就是成功的開始ㄎㄎ\n\n魏嘉緯：抓神獸囉！"
        aboutUsTextView.font = UIFont.systemFont(ofSize: 16)
        aboutUsTextView.isEditable = false
    }
    func setupTitleBarView(){
        titleBarView.backgroundColor = UIColor(red: 255/255, green: 184/255, blue:97/255, alpha: 1)
        titleBarView.addSubview(smallCircle)
        titleBarView.addSubview(titleLabel)
        titleLabel.text = "About Us"
        titleLabel.textColor = .white
        smallCircle.image = UIImage(named: "bar_circle_icon")
        smallCircle.contentMode = .scaleAspectFill
        
        let smallCircleSize = titleBarView.frame.height - 4
        smallCircle.snp.makeConstraints{(make) in
            make.left.equalTo(titleBarView).offset(10)
            make.width.equalTo(Int(smallCircleSize))
            make.right.equalTo(titleLabel.snp.left).offset(-10)
            make.top.equalTo(titleBarView).offset(2)
            make.height.equalTo(Int(smallCircleSize))
        }
        titleLabel.snp.makeConstraints{(make) in
            make.left.equalTo(smallCircle.snp.right).offset(10)
            make.right.equalTo(titleBarView).offset(-5)
            make.top.equalTo(titleBarView).offset(2)
            make.height.equalTo(Int(smallCircleSize))
        }
    }
    func hideContent(_ isHidden:Bool){
            self.aboutUsTextView.isHidden = isHidden
    }


}
