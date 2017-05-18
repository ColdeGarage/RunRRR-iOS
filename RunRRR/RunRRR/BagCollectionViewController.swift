//
//  BagCollectionViewController.swift
//  RunRRR
//
//  Created by Jacky Huang on 2017/4/5.
//  Copyright © 2017年 EEECamp. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

private let reuseIdentifier = "BagItemCell"

class BagCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    var delegate: segueBetweenViewController!
    private let refreshControl = UIRefreshControl()
    let LocalUserDefault = UserDefaults.standard
    var packs = [Pack]()
//    var items = [Item]()
    var bag = [[Item]]()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMenuBar()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(BagItemCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView!.contentInset = UIEdgeInsetsMake(90, 0, 0, 0)
        // Do any additional setup after loading the view.
        if #available(iOS 10.0, *){
            self.collectionView!.refreshControl = refreshControl
        } else{
            self.collectionView!.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        fetchPacks()
    }
    override func viewDidAppear(_ animated: Bool) {
        self.collectionView?.reloadData()
    }
    func refreshData(){
        self.collectionView?.reloadData()
        fetchPacks()
    }
    func setupMenuBar(){
        let menuBar : MenuBar = {
            let mb = MenuBar("Bag")
            return mb
        }()
        view.addSubview(menuBar)
        view.addConstraintWithFormat(format: "H:|[v0]|", views: menuBar)
        view.addConstraintWithFormat(format: "V:|-20-[v0(58)]|", views: menuBar)
        (menuBar.arrangedSubviews[0] as! UIButton).addTarget(self, action: #selector(segueToMap), for: .touchUpInside)
        (menuBar.arrangedSubviews[1] as! UIButton).addTarget(self, action: #selector(changeToMissions), for: .touchUpInside)
        (menuBar.arrangedSubviews[3] as! UIButton).addTarget(self, action: #selector(changeToMore), for: .touchUpInside)
    }
    func segueToMap(){
        dismiss(animated: true, completion: nil)
    }
    func changeToMissions(){
        delegate!.segueToMission()
    }
    func changeToMore(){
        delegate!.segueToMore()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return bag.count + 1
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! BagItemCell
        // Configure the cell
        if(indexPath.item == 0){  // the first block displays money
            cell.itemImage.image = UIImage(named: "money")
            cell.itemName.text = "金錢"
        }else{
            cell.itemName.text = bag[indexPath.item-1][0].name
//            cell.itemImage.image = UIImage(named: "money")
            cell.itemCount.text = String(bag[indexPath.item-1].count)
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width/3, height: view.frame.height/4)
    }
    
    let itemDetailView = ItemDetailView()
    
    func showItemDetail(_ item: Item){
        itemDetailView.showDetail(item)
    }
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
        
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        print("tapped")
//        let cell = collectionView.cellForItem(at: indexPath)
        if (indexPath.item != 0){
            let itemToDisplay = bag[indexPath.item-1][0] as Item
            showItemDetail(itemToDisplay)
        }
    }
    
    private func fetchPacks(){
        packs.removeAll()
//        items.removeAll()
        bag.removeAll()
        let UID = LocalUserDefault.integer(forKey: "RunRRR_UID")
        let packParameter : Parameters = ["operator_uid":UID, "uid":UID]
        Alamofire.request("\(API_URL)/pack/read", parameters: packParameter).responseJSON{ response in
            print("\(API_URL)/pack/read")
            switch response.result{
            case .success(let value):
                let packJSON = JSON(value)
                let packsArray = packJSON["payload"]["objects"].arrayValue
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
                    self.packs += [pack]
                }
            case .failure:
                print("error")
            }
            self.fetchItem()
        }
    }
    private func fetchItem(){
        for item in packs{
            if(item.itemClass == .tool){
                let UID = LocalUserDefault.integer(forKey: "RunRRR_UID")
                let toolsParameter : Parameters = ["operator_uid":UID, "tid":item.id as Any]
                Alamofire.request("\(API_URL)/tool/read", parameters:toolsParameter).responseJSON{ response in
//                    print(response)
                    switch(response.result){
                    case .success(let value):
                        let toolsJSON = JSON(value)
                        let toolsArray = toolsJSON["payload"]["objects"].arrayValue
                        let tool : Item = {
                            let item = Item()
                            item.itemClass = .tool
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
                let UID = LocalUserDefault.integer(forKey: "RunRRR_UID")
                let toolsParameter : Parameters = ["operator_uid":UID, "cid":item.id as Any]
                Alamofire.request("\(API_URL)/clue/read", parameters:toolsParameter).responseJSON{ response in
                    switch(response.result){
                    case .success(let value):
                        let cluesJSON = JSON(value)
                        let clueArray = cluesJSON["payload"]["objects"].arrayValue
                        let clue : Item = {
                            let item = Item()
                            item.itemClass = .clue
                            item.cid = clueArray[0]["cid"].intValue
                            item.content = clueArray[0]["content"].stringValue
                            item.name = "線索"
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
        self.collectionView?.reloadData()
    }
    
    private func putIntoBag(_ itemPutInto: Item){
        var itemIsExist: Bool = false
        var index = 0
        for item in bag{
            
            if(item[0].name == itemPutInto.name){
                itemIsExist = true
                bag[index].append(itemPutInto)
//                let indexOfItem = bag.index(of: item)
//                bag[indexOfItem].append(itemPutInto)
            }
            index += 1
        }
        if(itemIsExist == false){
            bag.append([itemPutInto])
        }
    }
    
    private func itemsDidFetch(){
        var total = 0
        for item in bag {
            total += item.count
        }
        if(total == packs.count){
//            self.items.sort(by: {$0.itemClass!.hashValue < $1.itemClass!.hashValue})
            self.collectionView?.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
}

@IBDesignable class BagItemCell: UICollectionViewCell{
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    let itemImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "sticker")
        image.layer.borderWidth = 1
        image.layer.borderColor = UIColor.black.cgColor
        return image
    }()
    let itemName: UILabel = {
        let name = UILabel()
        name.text = "Unknown"
        name.textAlignment = NSTextAlignment.center
        name.layer.borderWidth = 1
        name.layer.borderColor = UIColor.black.cgColor
        return name
    }()
    let itemCount: UILabel = {
        let count = UILabel()
        count.text = "99"
        count.textAlignment = NSTextAlignment.center
        return count
    }()
    func setupView(){
        addSubview(itemImage)
        addConstraintWithFormat(format: "H:|[v0]|", views: itemImage)
        addConstraintWithFormat(format: "V:|[v0(\(frame.width))]|", views: itemImage)
        addSubview(itemName)
        addConstraintWithFormat(format: "H:|[v0]|", views: itemName)
        addConstraintWithFormat(format: "V:|-\(frame.width)-[v0]|", views: itemName)
        addSubview(itemCount)
        addConstraintWithFormat(format: "H:|-\(frame.width/2)-[v0]-\(frame.width/10)-|", views: itemCount)
        addConstraintWithFormat(format: "V:|-\(frame.width/7*5)-[v0(\(frame.width/4))]|", views: itemCount)
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
