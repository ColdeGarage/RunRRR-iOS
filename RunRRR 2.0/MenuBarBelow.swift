//
//  MenuBarBelow.swift
//  RunRRR
//
//  Created by Jacky Huang on 2017/7/14.
//  Copyright © 2017年 EEECamp. All rights reserved.
//

import UIKit
import SnapKit

protocol segueViewController {
    func mapButtonIsTapped()
    func bagButtonIsTapped()
    func missionButtonIsTapped()
    func moreButtonIsTapped()
}


class MenuBarBelow : UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var delegate:segueViewController?
    var dataSource:segueViewController?
    
    var currentPage:String?
    
    let pages = ["Maps", "Missions", "Bags", "More"]
    let icons = ["tab_map","tab_mission","tab_bag","tab_more"]
    let iconsSel = ["tab_map_sel","tab_mission_sel","tab_bag_sel","tab_more_sel"]
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor(red: 183/255, green: 183/255, blue:183/255, alpha: 1)
        cv.delegate = self
        cv.dataSource = self
        return cv
    }()
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.frame.width/4-15, height: self.frame.height-25)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MenuBarCell
        cell.imageView2.image = UIImage(named: iconsSel[indexPath.item])
        cell.imageView.image = UIImage(named: icons[indexPath.item])

        cell.backgroundColor = UIColor(red: 183/255, green: 183/255, blue:183/255, alpha: 1)
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = CGFloat(0.5)
        cell.layer.shadowRadius = 3
        cell.layer.shadowOpacity = 0.8
        cell.layer.shadowOffset = CGSize.zero
        cell.layer.shadowColor = UIColor.darkGray.cgColor
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(2)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch(indexPath.item) {
            case 0:
                tappedMaps()
                break
            case 1:
                tappedMission()
                break
            case 2:
                tappedBag()
                break
            case 3:
                tappedMore()
                break
            default: break
        }
    }
    let cellId = "MenuBarCellId"
    
    @objc func tappedMaps(){
        delegate?.mapButtonIsTapped()
    }
    @objc func tappedBag(){
        delegate?.bagButtonIsTapped()
    }
    @objc func tappedMission(){
        delegate?.missionButtonIsTapped()
    }
    @objc func tappedMore(){
        delegate?.moreButtonIsTapped()
    }
    
    /* Initializing */
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(collectionView)
        self.backgroundColor = UIColor(red: 183/255, green: 183/255, blue:183/255, alpha: 1)
        
        collectionView.snp.makeConstraints{(make) in
            make.leftMargin.equalTo(0)
            make.rightMargin.equalTo(0)
            make.topMargin.equalTo(0)
            make.bottomMargin.equalTo(0)
        }
        collectionView.register(MenuBarCell.self, forCellWithReuseIdentifier: cellId)
    
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

class MenuBarCell : UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCellView()
        self.isSelected = false
    }
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleToFill
        
        return iv
    }()
    let imageView2: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleToFill
        return iv
    }()

    override var isSelected: Bool {
        didSet{
            imageView2.isHidden = !self.isSelected
        }
    }
    func setupCellView(){
        addSubview(imageView)
        addSubview(imageView2)

        imageView2.snp.makeConstraints{(make) in
            make.width.equalTo(self.snp.width)
            make.height.equalTo(self.snp.height)
            make.center.equalTo(self.snp.center)
        }
        
        imageView.snp.makeConstraints{(make) in
            make.width.equalTo(self.snp.width)
            make.height.equalTo(self.snp.height)
            make.center.equalTo(self.snp.center)
        }
    }
    
    /* Initializing */
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
