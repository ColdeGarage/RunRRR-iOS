//
//  MenuBarBelow.swift
//  RunRRR
//
//  Created by Jacky Huang on 2017/7/14.
//  Copyright © 2017年 EEECamp. All rights reserved.
//

import UIKit

protocol segueViewController {
    func segueToMaps()
    func segueToBags()
    func segueToMissions()
    func segueToMore()
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
        //cell.backgroundView = UIImageView.init(image: UIImage (named: icons[indexPath.item]))
        if(currentPage == pages[indexPath.item]){
            cell.imageView.image = UIImage(named: iconsSel[indexPath.item])
        }else{
            cell.imageView.image = UIImage(named: icons[indexPath.item])
        }
        cell.imageView2.image = UIImage(named: iconsSel[indexPath.item])
        
        
        cell.backgroundColor = UIColor(red: 183/255, green: 183/255, blue:183/255, alpha: 1)
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = CGFloat(0.5)
        cell.layer.shadowRadius = 3
        cell.layer.shadowOpacity = 0.8
        cell.layer.shadowOffset = CGSize.zero
        cell.layer.shadowColor = UIColor.darkGray.cgColor
        switch(indexPath.item){
        case 0:
            let tappedEvent = UITapGestureRecognizer(target: self, action: #selector(tappedMaps))
            cell.addGestureRecognizer(tappedEvent)
            break
        case 1:
            let tappedEvent = UITapGestureRecognizer(target: self, action: #selector(tappedMission))
            cell.addGestureRecognizer(tappedEvent)
            break
        case 2:
            let tappedEvent = UITapGestureRecognizer(target: self, action: #selector(tappedBag))
            cell.addGestureRecognizer(tappedEvent)
            break
        case 3:
            let tappedEvent = UITapGestureRecognizer(target: self, action: #selector(tappedMore))
            cell.addGestureRecognizer(tappedEvent)
            break
        default: break
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(2)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! MenuBarCell
        print(indexPath)
        cell.imageView.image = UIImage(named: iconsSel[indexPath.item])
    }
    let cellId = "MenuBarCellId"
    
    func tappedMaps(){
        delegate?.segueToMaps()
    }
    func tappedBag(){
        delegate?.segueToBags()
    }
    func tappedMission(){
        delegate?.segueToMissions()
    }
    func tappedMore(){
        delegate?.segueToMore()
    }
    
    /* Initializing */
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(collectionView)
        self.backgroundColor = UIColor(red: 183/255, green: 183/255, blue:183/255, alpha: 1)
        addConstraintWithFormat(format: "H:|-10-[v0]-10-|", views: collectionView)
        addConstraintWithFormat(format: "V:|-12-[v0]-5-|", views: collectionView)
        collectionView.register(MenuBarCell.self, forCellWithReuseIdentifier: cellId)
    
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

@IBDesignable class MenuBarCell : UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCellView()
    }
    
    
  /*  let pagesIconButton : UIButton = {
        let bt = UIButton()
        bt.layer.backgroundColor = UIColor(red: 228/255, green: 228/255, blue:228/255, alpha: 1).cgColor
        bt.layer.borderWidth = 1
        bt.layer.borderColor = UIColor.black.cgColor
        return bt
    }()*/
    
  /*  let pagesColorBar : UIView = {
        let view = UIView()
        view.layer.backgroundColor = UIColor.orange.cgColor
        return view
    }()*/
    
    let imageView: UIImageView = {
        let iv = UIImageView()
       // iv.image = UIImage(named: "ic_map")
       // iv.layer.borderWidth = 3
       // iv.layer.borderColor = UIColor.orange.cgColor
        iv.contentMode = .scaleToFill
        
        return iv
    }()
    let imageView2: UIImageView = {
        let iv = UIImageView()
     //   iv.backgroundColor = UIColor.blue
      //  iv.image = UIImage(named: "ic_map_sel")
        iv.contentMode = .center
        return iv
    }()
    
    
    override var isSelected: Bool {
        didSet{
            imageView.alpha = isSelected ?  0 : 1
        }
    }
    
    
    func setupCellView(){
     //   addSubview(pagesIconButton)
      //  addSubview(pagesColorBar)
        addSubview(imageView2)
        addSubview(imageView)
        
       // addConstraintWithFormat(format: "H:[v0]", views: pagesColorBar)
        addConstraintWithFormat(format: "H:|[v0]|", views: imageView)
        addConstraintWithFormat(format: "V:|[v0]|", views: imageView)
        addConstraintWithFormat(format: "H:|[v0]|", views: imageView2)
        addConstraintWithFormat(format: "V:|[v0]|", views: imageView2)
      //  addConstraintWithFormat(format: "V:|-0-[v0(3)]", views: pagesColorBar)
     //   addConstraintWithFormat(format: "H:|-0-[v0]-0-|", views: pagesIconButton)
        addConstraint(NSLayoutConstraint(item: imageView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: imageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: imageView2, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: imageView2, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
    }
    
    /* Initializing */
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
