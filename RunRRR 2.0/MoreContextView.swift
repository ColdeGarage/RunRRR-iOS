//
//  MoreContextView.swift
//  RunRRR 2.0
//
//  Created by Jacky Huang on 2018/5/27.
//  Copyright © 2018年 ColdeGarage. All rights reserved.
//

import UIKit

class MoreContextView: ContextView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.worker = MoreWorker()
        self.backgroundColor = .yellow
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
