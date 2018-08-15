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
    var router: MainViewControllerOutput?
    
    // Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.router = MainViewRouter(vc: self)
        
        if let flowLayout = mainContextView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
            flowLayout.minimumLineSpacing = 0
        }
        self.view.backgroundColor = .white
        mainContextView.isPagingEnabled = true
        initView()
        initLayout()

        updateConstraints()
        
//        self.router!.checkIsLogin()             // If not login, will segue to LoginViewController

    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (self.router!.checkIsLogin()){
            
        }
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
        mainContextView.register(MainContextViewCell.self,
                                 forCellWithReuseIdentifier: self.mainContextWorker.cellId)

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
    
    /* MenuBar Button Delegation   */
    /* When clicking on buttons... */
    
    internal func mapButtonIsTapped() {
        self.scrollToMap()
        updateConstraints()
    }
    
    internal func bagButtonIsTapped() {
        self.scrollToBag()
        updateConstraints()
    }
    
    internal func missionButtonIsTapped() {
        self.scrollToMission()
        updateConstraints()
    }
    
    internal func moreButtonIsTapped() {
        self.scrollToMore()
        updateConstraints()
    }
    
    
    
    private func scrollToMap() {
        let index = IndexPath(item: 0, section: 0)
        self.mainContextView.scrollToItem(at: index, at: .left, animated: true)
    }
    
    private func scrollToMission() {
        let index = IndexPath(item: 1, section: 0)
        self.mainContextView.scrollToItem(at: index, at: .left, animated: true)
    }
    
    private func scrollToBag() {
        let index = IndexPath(item: 2, section: 0)
        self.mainContextView.scrollToItem(at: index, at: .left, animated: true)
    }
    
    private func scrollToMore() {
        let index = IndexPath(item: 3, section: 0)
        self.mainContextView.scrollToItem(at: index, at: .left, animated: true)
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        super.prepare(for: segue, sender: sender)
//        switch(segue.identifier ?? ""){
//        case "ShowMissionDetail":
//            let missionDetailViewController = segue.destination as? MissionsDetailViewController
//            let selectedMission = sender as? MissionsData
//            missionDetailViewController?.mission = selectedMission
//        default: break
//            
//        }
//    }
}


