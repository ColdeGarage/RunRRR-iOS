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

class MainViewController: UIViewController {
    
    // Attribute
    let menuBar = UIView()
    var mainContextView = ContextView()
    let contextViews: [String: ContextView] = {
        let cvs: [String: ContextView] = [
            "Map": MapContextView(),
            "Bag": BagContextView(),
            "Mission": MissionContextView(),
            "More": MoreContextView()
        ]
        return cvs
    }()
    
    
    // Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
        initLayout()
        
//        self.mainContextView.removeFromSuperview()
        updateConstraints()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func initLayout() {
        self.menuBar.backgroundColor = UIColor.red
        self.view.addSubview(menuBar)
        self.view.addSubview(mainContextView)
        
        updateConstraints()
    }
    
    private func initView() {
        mainContextView = contextViews["Map"]!
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
}
