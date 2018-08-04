//
//  MoreContextView.swift
//  RunRRR 2.0
//
//  Created by Jacky Huang on 2018/5/27.
//  Copyright © 2018年 ColdeGarage. All rights reserved.
//

import UIKit
import SnapKit


class MoreContextView: ContextView {
    let moreMenuTableView = UITableView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.worker = MoreWorker(moreTableView: self.moreMenuTableView)
        self.moreMenuTableView.delegate = (self.worker as! UITableViewDelegate)
        self.moreMenuTableView.dataSource = (self.worker as! UITableViewDataSource)
        self.moreMenuTableView.register(BarcodeTableViewCell.self, forCellReuseIdentifier: "BarcodeCell")
        self.moreMenuTableView.register(AboutUsTableViewCell.self, forCellReuseIdentifier: "AboutUsCell")
        self.moreMenuTableView.register(DieTableViewCell.self, forCellReuseIdentifier: "DieCell")
        self.moreMenuTableView.register(SOSTableViewCell.self, forCellReuseIdentifier: "SOSCell")
        self.moreMenuTableView.register(LogoutTableViewCell.self, forCellReuseIdentifier: "LogoutCell")
        self.backgroundColor = UIColor.init(hexString: "#FAFBFC")
        
        self.addSubview(moreMenuTableView)
        moreMenuTableView.snp.makeConstraints{(make) in
            make.top.equalTo(self.snp.top).offset(20)
            make.left.equalTo(self.snp.left).offset(20)
            make.right.equalTo(self.snp.right).offset(20)
            make.bottom.equalToSuperview().inset(16)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillBeDisplayed() {
        print(moreMenuTableView)
        moreMenuTableView.reloadData()
    }
}
