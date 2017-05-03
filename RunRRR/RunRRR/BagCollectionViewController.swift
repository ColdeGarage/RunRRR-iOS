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
    
    let LocalUserDefault = UserDefaults.standard
    var packs: [Pack] = []
    var tools: [Tool] = []
    var clues: [Clue] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMenuBar()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(BagItemCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView!.contentInset = UIEdgeInsetsMake(90, 0, 0, 0)
        // Do any additional setup after loading the view.
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
        return tools.count + clues.count + 1
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! BagItemCell
        // Configure the cell
        if(indexPath.item == 0){  // the first block displays money
            cell.itemImage.image = UIImage(named: "money")
            cell.itemName.text = "金錢"
        } else if (indexPath.item <= tools.count){
            cell.itemName.text = tools[indexPath.item-1].name
            let imageURL = URL(string: tools[indexPath.item-1].imageURL!)
            let imageData = try? Data(contentsOf: imageURL!)
            cell.itemImage.image = UIImage(data: imageData!)
            cell.itemCount.text = "99"
        } else{
            cell.itemName.text = "線索"
            cell.itemCount.text = "99"
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
    
    func showItemDetail(_ item: BagItemCell){
        itemDetailView.showDetail()
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
        print("tapped")
        let cell = collectionView.cellForItem(at: indexPath)
        showItemDetail(cell as! BagItemCell)
    }
    
    private func fetchPacks(){
        let UID = LocalUserDefault.integer(forKey: "RunRRR_UID")
        let packParameter : Parameters = ["operator_uid":UID, "uid":UID]
        Alamofire.request("http://coldegarage.tech:8081/api/v1/pack/read", parameters: packParameter).responseJSON{ response in
            switch response.result{
            case .success(let value):
                let packJSON = JSON(value)
                let packsArray = packJSON["payload"]["objects"].arrayValue
                for eachPack in packsArray{
                    let pack: Pack = {
                        let item = Pack()
                        item.pid = eachPack["pid"].intValue
                        if(eachPack["class"].stringValue == "tool"){
                            item.itemClass = .tool
                        }else{
                            item.itemClass = .clue
                        }
                        item.id = eachPack["id"].intValue
                        return item
                    }()
                    self.packs.append(pack)
                }
            case .failure:
                print("error")
            }
            self.fetchTools()
            self.fetchClues()
            
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
        }
    }
    private func fetchTools(){
        for tool in packs{
            if(tool.itemClass == .tool){
                let UID = LocalUserDefault.integer(forKey: "RunRRR_UID")
                let toolsParameter : Parameters = ["operator_uid":UID, "tid":tool.id as Any]
                Alamofire.request("http://coldegarage.tech:8081/api/v1/tool/read", parameters:toolsParameter).responseJSON{ response in
                    switch(response.result){
                    case .success(let value):
                        let toolsJSON = JSON(value)
                        let tool : Tool = {
                            let tool = Tool()
                            tool.tid = toolsJSON["payload"]["objects"]["tid"].intValue
                            tool.content = toolsJSON["payload"]["objects"]["content"].stringValue
                            tool.expireSec = toolsJSON["payload"]["objects"]["expire"].intValue
                            tool.imageURL = toolsJSON["payload"]["objects"]["url"].stringValue
                            tool.price = toolsJSON["payload"]["objects"]["price"].intValue
                            tool.name = toolsJSON["payload"]["objects"]["title"].stringValue
                            return tool
                        }()
                        self.tools.append(tool)
                    case .failure:
                        print("error")
                    }
                }
            }
        }
    }
    private func fetchClues(){
        for clue in packs{
            if(clue.itemClass == .clue){
                let UID = LocalUserDefault.integer(forKey: "RunRRR_UID")
                let cluesParameter : Parameters = ["operator_uid":UID, "cid":clue.id as Any]
                Alamofire.request("http://coldegarage.tech:8081/api/v1/clue/read", parameters:cluesParameter).responseJSON{ response in
                    switch(response.result){
                    case .success(let value):
                        let cluesJSON = JSON(value)
                        let clue : Clue = {
                            let clue = Clue()
                            clue.content = cluesJSON["payload"]["objects"]["content"].stringValue
                            clue.cid = cluesJSON["payload"]["objects"]["cid"].intValue
                            return clue
                        }()
                        self.clues.append(clue)
                    case .failure:
                        print("error")
                    }
                }
            }
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
