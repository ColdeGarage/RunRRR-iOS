//
//  MainViewController.swift
//  RunRRR 2.0
//
//  Created by Jacky Huang on 2018/5/27.
//  Copyright © 2018年 ColdeGarage. All rights reserved.
//

import GoogleMaps
import UIKit
import SnapKit

class MainViewController: UIViewController, segueViewController {
    // Attribute
    let menuBar = MenuBarBelow()
    let mainContextView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return cv
    }()
    let mainContextWorker = MainContextWorker()
    
    
    // Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        if let flowLayout = mainContextView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
        }
        initView()
        initLayout()
        
//        self.mainContextView.removeFromSuperview()
        updateConstraints()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func initLayout() {
        self.view.addSubview(menuBar)
        self.view.addSubview(mainContextView)
        
        updateConstraints()
    }
    
    private func initView() {
        mainContextView.delegate = self.mainContextWorker
        mainContextView.dataSource = self.mainContextWorker
        mainContextView.register(MainContextViewCell.self, forCellWithReuseIdentifier: self.mainContextWorker.cellId)
        //        mainContextView = contextViews["Map"]!
        
        
        self.menuBar.delegate = self
        self.menuBar.dataSource = self
    }
    
    private func updateConstraints() {
        menuBar.snp.makeConstraints{(make) in
            make.bottom.equalTo(view)
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.height.equalTo(view).multipliedBy(0.15)
        }
        mainContextView.snp.makeConstraints{(make) in
            if #available(iOS 11, *) {
                make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin)
            }
            else {
                make.top.equalTo(view.snp.topMargin)
            }
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.bottom.equalTo(menuBar.snp.top)
        }
    }
    
    internal func segueToMaps() {
//        self.mainContextView.removeFromSuperview()
//        self.mainContextView = contextViews["Map"]!
        updateConstraints()
    }
    
    internal func segueToBags() {
//        self.mainContextView.removeFromSuperview()
//        self.mainContextView = contextViews["Bag"]!
        updateConstraints()
    }
    
    internal func segueToMissions() {
//        self.mainContextView.removeFromSuperview()
//        self.mainContextView = contextViews["Mission"]!
        updateConstraints()
    }
    
    internal func segueToMore() {
//        self.mainContextView.removeFromSuperview()
//        self.mainContextView = contextViews["More"]!
        updateConstraints()
    }
    
}


