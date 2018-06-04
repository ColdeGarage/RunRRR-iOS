//
//  MainContextWorker.swift
//  RunRRR 2.0
//
//  Created by Jacky Huang on 2018/6/5.
//  Copyright © 2018年 ColdeGarage. All rights reserved.
//

import UIKit

class MainContextWorker: NSObject, Worker, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    let cellId: String = "mainContextViewCell"
    let contextViews: [String: ContextView] = {
        let cvs: [String: ContextView] = [
            "Map": MapContextView(),
            "Bag": BagContextView(),
            "Mission": MissionContextView(),
            "More": MoreContextView()
        ]
        return cvs
    }()
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath)
        
        cell.backgroundColor = .blue
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
}

class MainContextViewCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
