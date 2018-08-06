//
//  BagWorker.swift
//  RunRRR 2.0
//
//  Created by Jacky Huang on 2018/5/27.
//  Copyright © 2018年 ColdeGarage. All rights reserved.
//

import UIKit
import Alamofire
import SnapKit
import SwiftyJSON

class BagWorker: NSObject, Worker, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    let UID = UserDefaults.standard.integer(forKey: "RunRRR_UID")
    let token = UserDefaults.standard.string(forKey: "RunRRR_Token")!
    var packs = [Pack]()
    var bag = [[Item]]()
    var memberMoney: Int?
    var bagCollectionView: UICollectionView?
    
    private let reuseIdentifier = "BagItemCell"
    
    func refreshData(){
        fetchMoney()
        fetchPacks()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return bag.count + 1
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! BagItemCell
        print("number : ",indexPath)
        // Configure the cell
        if(indexPath.item == 0){  // the first block displays money
            cell.itemImage.image = UIImage(named: "money")
            cell.itemName.text = "金錢"
            cell.itemCount.text = memberMoney?.description
        }else{
            cell.itemName.text = bag[indexPath.item-1].last?.name
            if let imageUrl = bag[indexPath.item-1].last?.imageURL {
                let imageURLAllowedCharacters = imageUrl.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
                let downloadURL = "\(CONFIG.API_PREFIX.ROOT)/download/img/\(imageURLAllowedCharacters!)"
                Alamofire.request(downloadURL).responseData{
                    responds in
                    if let image = responds.result.value{
                        cell.itemImage.image = UIImage(data: image)
                    }
                }
            }
            cell.itemCount.text = String(self.bag[indexPath.item-1].count)
        }
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width/3, height: collectionView.frame.height/5)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (indexPath.item != 0){
            let itemToDisplay = bag[indexPath.item-1].last! as Item
            showItemDetail(itemToDisplay, itemCount: bag[indexPath.item-1].count)
        }
    }
    
    let itemDetailView = ItemDetailView()
    
    func showItemDetail(_ item: Item, itemCount:Int){
        itemDetailView.worker = self
        itemDetailView.showDetail(item, itemCount: itemCount)
    }

    
    func fetchMoney(){
        let UID = UserDefaults.standard.integer(forKey: "RunRRR_UID")
        let token = UserDefaults.standard.string(forKey: "RunRRR_Token")!
        let moneyParameter : Parameters = ["operator_uid":UID, "token":token, "uid":UID]
        Alamofire.request("\(CONFIG.API_PREFIX.ROOT)/member/read", parameters: moneyParameter).responseJSON{ response in
            switch response.result{
            case .success(let value):
                let memberReadJSON = JSON(value)
                guard memberReadJSON["brea"].intValue == 0 else{
                    print("memberReadJSON error!")
                    return
                }
                let memberReadArray = memberReadJSON["payload"]["objects"].arrayValue
                guard let money = memberReadArray[0]["money"].intValue as Int? else {
                    //nil
                    return
                }
                self.memberMoney = money
                print("Money : ",self.memberMoney!)
                self.bagCollectionView?.reloadData()
            case .failure:
                print("error")
            }
        }
    }
    var bagTemp = [[Item]]()
    var packTemp = [Pack]()
    func fetchPacks(){
        // Remove history items
        //        packs.removeAll()
        //        bag.removeAll()
        bagTemp.removeAll()
        packTemp.removeAll()
        
        //Start calling API
        let UID = UserDefaults.standard.integer(forKey: "RunRRR_UID")
        let token = UserDefaults.standard.string(forKey: "RunRRR_Token")!
        let packParameter : Parameters = ["operator_uid":UID,"token":token, "uid":UID]
        Alamofire.request("\(CONFIG.API_PREFIX.ROOT)/pack/read", parameters: packParameter).responseJSON{ response in
            
            switch response.result{
            case .success(let value):
                
                //Parse the "packs" into array
                let packJSON = JSON(value)
                guard let packsArray = packJSON["payload"]["objects"].arrayValue as Array? else{
                    return
                }
                
                for eachPack in packsArray{
                    let pack: Pack = {
                        let item = Pack()
                        item.pid = eachPack["pid"].intValue
                        if(eachPack["class"].stringValue == "TOOL"){
                            item.itemClass = .tool
                        }else{
                            item.itemClass = .clue
                        }
                        item.id = eachPack["id"].intValue
                        return item
                    }()
                    self.packTemp += [pack]
                    //                    self.packs += [pack]
                }
                
            case .failure:
                print("error")
            }
            print("fetchItem")
            self.packs = self.packTemp
            self.fetchItem()
            //            self.packs.sort(by: {($0.itemClass?.hashValue)! > ($1.itemClass?.hashValue)!})
            //            for i in self.packs{
            //                print(i.itemClass.debugDescription)
            //            }
        }
    }
    private func fetchItem(){
        let UID = UserDefaults.standard.integer(forKey: "RunRRR_UID")
        let token = UserDefaults.standard.string(forKey: "RunRRR_Token")!
        for itemToFetch in packTemp{
            if(itemToFetch.itemClass == .tool){
                let toolsParameter : Parameters = ["operator_uid":UID,"token":token, "tid":itemToFetch.id as Any]
                Alamofire.request("\(CONFIG.API_PREFIX.ROOT)/tool/read", parameters:toolsParameter).responseJSON{ response in
                    print(response)
                    switch(response.result){
                    case .success(let value):
                        let toolsJSON = JSON(value)
                        guard let toolsArray = toolsJSON["payload"]["objects"].arrayValue as Array?
                            else{
                                return
                        }
                        let tool : Item = {
                            let item = Item()
                            item.itemClass = .tool
                            item.pid = itemToFetch.pid
                            item.tid = toolsArray[0]["tid"].intValue
                            item.content = toolsArray[0]["content"].stringValue
                            item.expireSec = toolsArray[0]["expire"].intValue
                            item.imageURL = toolsArray[0]["url"].stringValue
                            item.price = toolsArray[0]["price"].intValue
                            item.name = toolsArray[0]["title"].stringValue
                            return item
                        }()
                        //                        print(tool)
                        self.putIntoBag(tool)
                        //                        self.items += [tool]
                        
                    case .failure:
                        print("error")
                    }
                    self.itemsDidFetch()
                }
            }
            else{
                let toolsParameter : Parameters = ["operator_uid":UID,"token":token, "cid":itemToFetch.id as Any]
                Alamofire.request("\(CONFIG.API_PREFIX.ROOT)/clue/read", parameters:toolsParameter).responseJSON{ response in
                    switch(response.result){
                    case .success(let value):
                        let cluesJSON = JSON(value)
                        guard let clueArray = cluesJSON["payload"]["objects"].arrayValue as Array?
                            else{
                                return
                        }
                        let clue : Item = {
                            let item = Item()
                            item.itemClass = .clue
                            item.pid = itemToFetch.pid
                            item.cid = clueArray[0]["cid"].intValue
                            item.content = clueArray[0]["content"].stringValue
                            item.name = "線索"
                            item.imageURL = "clue.jpg"
                            return item
                        }()
                        //                        self.items += [clue]
                        self.putIntoBag(clue)
                    case .failure:
                        print("error")
                    }
                    self.itemsDidFetch()
                }
            }
        }
        //self.bag = self.bagTemp
        //self.collectionView?.reloadData()
        //self.refreshControl.endRefreshing()
    }
    
    private func putIntoBag(_ itemPutInto: Item){
        var itemIsExist: Bool = false
        var index = 0
        for item in bagTemp{
            
            if(item[0].name == itemPutInto.name){
                itemIsExist = true
                bagTemp[index].append(itemPutInto)
                //                let indexOfItem = bag.index(of: item)
                //                bag[indexOfItem].append(itemPutInto)
            }
            index += 1
        }
        if(itemIsExist == false){
            bagTemp.append([itemPutInto])
        }
    }
    
    private func itemsDidFetch(){
        var sortTool = [[Item]]()
        var sortClue = [Item]()
        var total = 0
        for item in bagTemp {
            total += item.count
        }
        if(total == packTemp.count){
            for item in bagTemp{
                if item.last?.itemClass == .clue{
                    for clue in item{
                        sortClue.append(clue)
                    }
                }else{
                    sortTool.append(item)
                }
            }
            sortTool.sort(by: {$0[0].tid! < $1[0].tid!})
            sortClue.sort(by: {$0.pid! < $1.pid!})
            self.bagTemp = sortTool
            for clue in sortClue{
                self.bagTemp.append([clue])
            }
            self.bag = self.bagTemp
            self.bagCollectionView?.reloadData()
//            self.refreshControl.endRefreshing()
        }
    }
}


class BagItemCell: UICollectionViewCell{
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    let itemImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "sticker")
        //image.layer.borderWidth = 1
        image.layer.borderColor = UIColor.black.cgColor
        image.layer.cornerRadius = 15
        image.layer.masksToBounds = true
        return image
    }()
    let itemName: UILabel = {
        let name = UILabel()
        name.text = "Unknown"
        name.textAlignment = NSTextAlignment.center
        name.font = UIFont.systemFont(ofSize: 12)
        name.layer.borderColor = UIColor.black.cgColor

        return name
    }()
    let itemCount: UILabel = {
        let count = UILabel()
        count.text = "99"
        count.textAlignment = NSTextAlignment.center
        count.layer.borderWidth = 1
        count.layer.borderColor = UIColor.white.cgColor
        count.layer.backgroundColor = UIColor.white.cgColor
        count.layer.cornerRadius = 14
        count.layer.masksToBounds = true
        count.adjustsFontSizeToFitWidth = true
        return count
    }()
    func setupView(){
        self.backgroundColor = .red
        addSubview(itemImage)
        addSubview(itemName)
        addSubview(itemCount)
        
        itemImage.snp.makeConstraints{(make) in
            make.centerX.equalToSuperview()
            make.width.equalTo(self).multipliedBy(0.75)
            make.top.equalTo(self.snp.bottom).multipliedBy(0.1)
            make.bottom.equalToSuperview().multipliedBy(0.75)
        }
        
        itemName.snp.makeConstraints{(make) in
            make.centerX.equalToSuperview()
            make.width.equalTo(self).multipliedBy(0.75)
            make.bottom.equalTo(self.snp.bottom).multipliedBy(0.9)
            make.height.equalToSuperview().dividedBy(8)
        }
        
        itemCount.snp.makeConstraints{(make) in
            make.right.equalTo(self.snp.right).multipliedBy(0.97)
            make.width.equalToSuperview().dividedBy(4)
            make.top.equalTo(self.snp.bottom).multipliedBy(0.025)
            make.height.equalToSuperview().dividedBy(4)
        }
//        addConstraintWithFormat(format: "H:|-\(frame.width/8)-[v0]-\(frame.width/8)-|", views: itemImage)
//        addConstraintWithFormat(format: "V:|-\(frame.width/10)-[v0]-\(frame.width/4)-|", views: itemImage)
//        addConstraintWithFormat(format: "H:|-\(frame.width/8)-[v0]-\(frame.width/8)-|", views: itemName)
//        addConstraintWithFormat(format: "V:[v0(\(frame.width/8))]-\(frame.width/10)-|", views: itemName)
//        addConstraintWithFormat(format: "H:[v0(\(frame.width/4))]-\(frame.width/40)-|", views: itemCount)
//        addConstraintWithFormat(format: "V:|-\(frame.width/40)-[v0(\(frame.width/4))]", views: itemCount)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
