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

class BagCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, segueViewController {
    private let refreshControl = UIRefreshControl()
    let LocalUserDefault = UserDefaults.standard
    let UID = UserDefaults.standard.integer(forKey: "RunRRR_UID")
    let token = UserDefaults.standard.string(forKey: "RunRRR_Token")!
    var packs = [Pack]()
//    var items = [Item]()
    var bag = [[Item]]()
    var prevVC: UIViewController?
    var memberMoney: Int?
    let menuBar : MenuBarBelow = {
        let menubar = MenuBarBelow()
        menubar.currentPage = "Bags"
        return menubar
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        prevVC?.dismiss(animated: false, completion: nil)
        //setupMenuBar()
        
        self.view.addSubview(menuBar)
        self.view.addConstraintWithFormat(format: "H:|[v0]|", views: menuBar)
        self.view.addConstraintWithFormat(format: "V:[v0(\(self.view.frame.height/6))]-0-|", views: menuBar)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(BagItemCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView!.contentInset = UIEdgeInsetsMake(20, 0, 0, 0)
        // Do any additional setup after loading the view.
        if #available(iOS 10.0, *){
            self.collectionView!.refreshControl = refreshControl
        } else{
            self.collectionView!.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        fetchMoney()
        fetchPacks()
        menuBar.delegate = self
        menuBar.dataSource = self
    }
    override func viewDidAppear(_ animated: Bool) {
        self.collectionView?.reloadData()
    }
    func refreshData(){
        self.collectionView?.reloadData()
        fetchPacks()
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
            cell.itemCount.text = memberMoney?.description
        }else{
            cell.itemName.text = bag[indexPath.item-1].last?.name
            if let imageUrl = bag[indexPath.item-1].last?.imageURL {
                let imageURLAllowedCharacters = imageUrl.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
                let downloadURL = "\(API_URL)/download/img/\(imageURLAllowedCharacters!)"
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
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width/3, height: view.frame.height/5)
    }
    
    let itemDetailView = ItemDetailView()
    
    func showItemDetail(_ item: Item, itemCount:Int){
        itemDetailView.delegateViewController = self
        itemDetailView.showDetail(item, itemCount: itemCount)
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
            let itemToDisplay = bag[indexPath.item-1].last! as Item
            showItemDetail(itemToDisplay, itemCount: bag[indexPath.item-1].count)
        }
    }

    func fetchMoney(){
        let moneyParameter : Parameters = ["operator_uid":UID, "token":token, "uid":UID]
        Alamofire.request("\(API_URL)/member/read", parameters: moneyParameter).responseJSON{ response in
            switch response.result{
            case .success(let value):
                let memberReadJSON = JSON(value)
                let memberReadArray = memberReadJSON["payload"]["objects"].arrayValue
                self.memberMoney = memberReadArray[0]["money"].intValue
            case .failure:
                print("error")
            }
        }
    }
    
    func fetchPacks(){
        // Remove history items
        packs.removeAll()
        bag.removeAll()
        
        //Start calling API
        let UID = LocalUserDefault.integer(forKey: "RunRRR_UID")
        let packParameter : Parameters = ["operator_uid":UID,"token":self.token, "uid":UID]
        Alamofire.request("\(API_URL)/pack/read", parameters: packParameter).responseJSON{ response in
            switch response.result{
            case .success(let value):
                
                //Parse the "packs" into array
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
//            self.packs.sort(by: {($0.itemClass?.hashValue)! > ($1.itemClass?.hashValue)!})
//            for i in self.packs{
//                print(i.itemClass.debugDescription)
//            }
        }
    }
    private func fetchItem(){
        for itemToFetch in packs{
            if(itemToFetch.itemClass == .tool){
                let UID = LocalUserDefault.integer(forKey: "RunRRR_UID")
                let toolsParameter : Parameters = ["operator_uid":UID,"token":self.token, "tid":itemToFetch.id as Any]
                Alamofire.request("\(API_URL)/tool/read", parameters:toolsParameter).responseJSON{ response in
//                    print(response)
                    switch(response.result){
                    case .success(let value):
                        let toolsJSON = JSON(value)
                        let toolsArray = toolsJSON["payload"]["objects"].arrayValue
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
                let UID = LocalUserDefault.integer(forKey: "RunRRR_UID")
                let toolsParameter : Parameters = ["operator_uid":UID,"token":self.token, "cid":itemToFetch.id as Any]
                Alamofire.request("\(API_URL)/clue/read", parameters:toolsParameter).responseJSON{ response in
                    switch(response.result){
                    case .success(let value):
                        let cluesJSON = JSON(value)
                        let clueArray = cluesJSON["payload"]["objects"].arrayValue
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
        var sortTool = [[Item]]()
        var sortClue = [Item]()
        var total = 0
        for item in bag {
            total += item.count
        }
        if(total == packs.count){
//          self.items.sort(by: {$0.itemClass!.hashValue < $1.itemClass!.hashValue})
            for item in bag{
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
            self.bag = sortTool
            for clue in sortClue{
                self.bag.append([clue])
            }
            self.collectionView?.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
    
    func segueToMissions() {
        let vc = UIStoryboard(name: "Missions", bundle: nil).instantiateViewController(withIdentifier: "MissionsViewController") as! MissionsViewController
        //print(vc.description)
        vc.prevVC = self
        self.present(vc, animated: false, completion: nil)
    }
    func segueToMore() {
        let vc = UIStoryboard(name: "More", bundle: nil).instantiateViewController(withIdentifier: "MoreViewController") as! MoreViewController
        //print(vc.description)
        vc.prevVC = self
        self.present(vc, animated: false, completion: nil)
    }
    func segueToBags() {
        
    }
    func segueToMaps() {
        dismiss(animated: false, completion: nil)
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
        //name.layer.borderWidth = 1
        name.layer.borderColor = UIColor.black.cgColor
        
        //name.lineBreakMode = NSLineBreakMode.byCharWrapping
        //name.numberOfLines = 6
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
        return count
    }()
    func setupView(){
        addSubview(itemImage)
        addConstraintWithFormat(format: "H:|-\(frame.width/8)-[v0]-\(frame.width/8)-|", views: itemImage)
        addConstraintWithFormat(format: "V:|-\(frame.width/10)-[v0]-\(frame.width/4)-|", views: itemImage)
        addSubview(itemName)
        addConstraintWithFormat(format: "H:|-\(frame.width/8)-[v0]-\(frame.width/8)-|", views: itemName)
        addConstraintWithFormat(format: "V:[v0(\(frame.width/8))]-\(frame.width/10)-|", views: itemName)
        addSubview(itemCount)
        addConstraintWithFormat(format: "H:[v0(\(frame.width/4))]-\(frame.width/40)-|", views: itemCount)
        addConstraintWithFormat(format: "V:|-\(frame.width/40)-[v0(\(frame.width/4))]", views: itemCount)
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
