//
//  MainContextWorker.swift
//  RunRRR 2.0
//
//  Created by Jacky Huang on 2018/6/5.
//  Copyright © 2018年 ColdeGarage. All rights reserved.
//

import UIKit
import SnapKit

class MainContextWorker: NSObject, Worker, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    let cellId: String = "mainContextViewCell"
    let contextViewName: [String] = ["Map", "Mission", "Bag", "More"]
    let contextViews: [String: ContextView] = {
        let cvs: [String: ContextView] = [
            "Map": MapContextView(),
            "Mission": MissionContextView(),
            "Bag": BagContextView(),
            "More": MoreContextView()
        ]
        return cvs
    }()
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MainContextViewCell
        cell.mainView = self.contextViews[contextViewName[indexPath.item]]!
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let mainCell = cell as! MainContextViewCell
        
        mainCell.cellWillBeDisplayed()
    }
}

class MainContextViewCell: UICollectionViewCell {
    var mainView: ContextView? {
        willSet{
            self.mainView?.removeFromSuperview()
        }
        didSet{
            guard let mv = mainView else {
                return
            }
            self.addSubview(mv)
            updateMainViewConstraints()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateMainViewConstraints() {
        mainView?.snp.makeConstraints{(make) in
            make.top.equalTo(self.snp.top)
            make.bottom.equalTo(self.snp.bottom)
            make.left.equalTo(self.snp.left)
            make.right.equalTo(self.snp.right)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
//        self.mainView?.removeFromSuperview()
        self.backgroundColor = .black
        
    }
    
    func cellWillBeDisplayed() {
        guard let mv = self.mainView else {
            fatalError("No mainView exists!")
        }
        mv.viewWillBeDisplayed()
    }
}
