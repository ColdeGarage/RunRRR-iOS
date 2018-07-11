//
//  MissionContextView.swift
//  RunRRR 2.0
//
//  Created by Jacky Huang on 2018/5/27.
//  Copyright © 2018年 ColdeGarage. All rights reserved.
//

import UIKit
import SnapKit

class MissionContextView: ContextView {
    let missionQueue = UITableView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.worker = MissionWorker()
        
        missionQueue.delegate = (worker as! UITableViewDelegate)
        missionQueue.dataSource = (worker as! UITableViewDataSource)
        missionQueue.register(MissionTableCell.self, forCellReuseIdentifier: "missionCell")
        
        setupLayout()
    }
    
    private func setupLayout() {
        addSubview(missionQueue)
        missionQueue.snp.makeConstraints {(make) in
            make.top.equalTo(self.snp.top)
            make.bottom.equalTo(self.snp.bottom)
            make.left.equalTo(self.snp.left)
            make.right.equalTo(self.snp.right)
            // NOTE: tableView and ContextView have no common ancestor.
            // Solved!: missing addSubview()
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillBeDisplayed() {
        
    }
}
