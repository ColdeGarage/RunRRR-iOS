//
//  BagContextView.swift
//  RunRRR 2.0
//
//  Created by Jacky Huang on 2018/5/27.
//  Copyright © 2018年 ColdeGarage. All rights reserved.
//

import UIKit
import SnapKit

class BagContextView: ContextView {
    lazy var bagCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor(red: 230/255, green: 230/255, blue:230/255, alpha: 1)
        cv.delegate = (self.worker as! UICollectionViewDelegate)
        cv.dataSource = (self.worker as! UICollectionViewDataSource)
        return cv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.worker = BagWorker()
        
        bagCollectionView.register(BagItemCell.self, forCellWithReuseIdentifier: "BagItemCell")
        self.addSubview(bagCollectionView)
        
        bagCollectionView.snp.makeConstraints{(make) in
            make.top.equalToSuperview().inset(20)
            make.left.right.bottom.equalToSuperview()
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillBeDisplayed() {
        
    }
}
