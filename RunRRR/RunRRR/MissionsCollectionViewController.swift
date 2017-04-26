//
//  Missons.swift
//  RunRRR
//
//  Created by Jacky Huang on 2017/4/4.
//  Copyright © 2017年 EEECamp. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

@IBDesignable class MissionsCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    var missionShowList = [MissionsData]()
    var completeMissionList = [MissionsData]()
    private let refreshControl = UIRefreshControl()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.register(MissionsCell.self, forCellWithReuseIdentifier: "missionsCell")
        collectionView?.contentInset = UIEdgeInsetsMake(60, 0, 0, 0)
        if #available(iOS 10.0, *){
            collectionView?.refreshControl = refreshControl
        } else{
            collectionView?.addSubview(refreshControl)
        }
        // Configure Refresh Control
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        setupMenuBar()
        loadMissions()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return missionShowList.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "missionsCell", for: indexPath)
            as! MissionsCell
        
        cell.missionName.text = self.missionShowList[indexPath.row].title
        cell.missionTiming.text = self.missionShowList[indexPath.row].timeEnd
        switch missionShowList[indexPath.row].type{
        case "1":
            cell.missionPriorityThumbnail.text = "U"
        case "2":
            cell.missionPriorityThumbnail.text = "M"
        case "3":
            cell.missionPriorityThumbnail.text = "S"
        default:
            cell.missionPriorityThumbnail.text = "?"
        }
        //cell.missionPriorityThumbnail.text = missionShow[indexPath.row].type
        switch self.missionShowList[indexPath.row].check {
        case "unsolved":
            cell.missionStatus.backgroundColor = UIColor.green
        case "review":
            cell.missionStatus.backgroundColor = UIColor.blue
        case "complete":
            cell.missionStatus.backgroundColor = UIColor.darkGray
        default:
            cell.missionStatus.backgroundColor = UIColor.brown
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 80)
    }
    //Mark : Model start here
    func loadMissions(){
        Alamofire.request("file:///Users/yi-chun/Desktop/RunRRR/RunRRR/TestingJson/missionRead.json").responseJSON{ response in
            switch response.result{
                
            case .success(let value):
                let missionsJson = JSON(value)
                let missions = missionsJson["payload"]["objects"].arrayValue
                for mission in missions{
                    let mid = mission["mid"].intValue
                    let title = mission["title"].stringValue
                    let content = mission["content"].stringValue
                    let timeStart = mission["time_start"].stringValue
                    let timeEnd = mission["time_end"].stringValue
                    let price = mission["price"].intValue
                    let clue = mission["clue"].intValue
                    let type = mission["class"].stringValue
                    let score = mission["score"].intValue
                    let locationE = mission["location_e"].doubleValue
                    let locationN = mission["location_n"].doubleValue
                    
                    
                    guard let missionItem = MissionsData(mid:mid,title:title,content:content,timeStart:timeStart,timeEnd:timeEnd,price:price,clue:clue,type:type,score:score,locationE:locationE,locationN:locationN) else{
                        fatalError("Unable to load missionItem")
                    }
                    self.missionShowList += [missionItem]
                    
                    
                }
            case .failure(let error):
                print(error)
                
            }
            self.missionShowList.sort(by: {$0.type < $1.type})
            
            Alamofire.request("file:///Users/yi-chun/Desktop/RunRRR/RunRRR/TestingJson/reportRead.json").responseJSON{ response in
                switch response.result{
                    
                case .success(let value):
                    let missionReportJson = JSON(value)
                    let missionReport = missionReportJson["payload"]["objects"].arrayValue
                    let serverTime = missionReportJson["server_time"].stringValue.components(separatedBy: "T")[1]
                    let serverHour = Int(serverTime.components(separatedBy: ":")[0])!
                    let serverMin = Int(serverTime.components(separatedBy: ":")[1])!
                    
                    //filter the complete mission to the button
                    for missionStatus in missionReport{
                        let mid = missionStatus["mid"].intValue
                        let status = missionStatus["status"].intValue
                        let index = self.missionShowList.index(where:{$0.mid == mid})
                        
                        //if mission complete
                        if status == 1 {
                            self.missionShowList[index!].check = "complete"
                            let missionComplete = self.missionShowList[index!]
                            self.missionShowList.remove(at: index!)
                            self.completeMissionList += [missionComplete]
                        }
                            //if mission is reviewing
                        else{
                            self.missionShowList[index!].check = "review"
                        }
                    }
                    
                    //filter out the fail mission
                    var idxToRemove = Set<Int>()
                    for idx in 0...self.missionShowList.count-1{
                        let timeHour = Int(self.missionShowList[idx].timeEnd.components(separatedBy: ":")[0])!
                        let timeMin = Int(self.missionShowList[idx].timeEnd.components(separatedBy: ":")[1])!
                        if self.missionShowList[idx].check != "review"{
                            if timeHour < serverHour{
                                idxToRemove.insert(idx)
                            }
                            else if timeHour == serverHour{
                                if timeMin < serverMin{
                                    idxToRemove.insert(idx)
                                }
                            }
                        }
                    }
                    self.missionShowList = self.missionShowList
                        .enumerated()
                        .filter {!idxToRemove.contains($0.offset)}
                        .map {$0.element}
                    
                    
                    
                case .failure(let error):
                    print(error)
                }
                self.missionShowList += self.completeMissionList
                self.collectionView?.reloadData()
            }
            
        }
        
    }

    let menuBar: MenuBar = {
        let mb = MenuBar()
        return mb
    }()
    private func setupMenuBar(){
        view.addSubview(menuBar)
        view.addConstraintWithFormat(format: "H:|[v0]|", views: menuBar)
        view.addConstraintWithFormat(format: "V:|-0-[v0(50)]|", views: menuBar)
    }
    func refreshData(){
        self.loadMissions()
        refreshControl.endRefreshing()
    }
}


@IBDesignable class MissionsCell: UICollectionViewCell{
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    let missionPriorityThumbnail: UILabel = {
        let priorityLabel = UILabel()
        priorityLabel.text = "主"
        priorityLabel.textAlignment = NSTextAlignment(rawValue: 1)!
        priorityLabel.layer.borderWidth = CGFloat(2)
        priorityLabel.layer.borderColor = UIColor.black.cgColor
        priorityLabel.layer.cornerRadius = 0
        return priorityLabel
    }()
    let seperateCell: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.blue
        return view
    }()
    let missionName: UILabel = {
        let name = UILabel()
        name.text = "Example Mission"
        name.layer.borderColor = UIColor.black.cgColor
        name.layer.borderWidth = CGFloat(1)
        name.textAlignment = NSTextAlignment(rawValue: 1)!
        return name
    }()
    let missionTiming: UILabel = {
        let time = UILabel()
        time.text = "23:59"
        time.layer.borderWidth = CGFloat(1)
        return time
    }()
    let missionStatus: UIImageView = {
        let status = UIImageView()
        status.backgroundColor = UIColor.green
        status.layer.borderWidth = CGFloat(1)
        return status
    }()
    func setupView(){
        addSubview(missionPriorityThumbnail)
        //addSubview(seperateCell)
        addSubview(missionName)
        addSubview(missionTiming)
        addSubview(missionStatus)
        //Vertical
        addConstraintWithFormat(format: "V:|[v0]|", views: missionPriorityThumbnail)
        addConstraintWithFormat(format: "V:|[v0]|", views: missionName)
        addConstraintWithFormat(format: "V:|[v0]-0-[v1(50)]|", views: missionTiming, missionStatus)
        //Horizonal
        addConstraintWithFormat(format: "H:|[v0(80)]-0-[v1]-0-[v2(50)]|", views: missionPriorityThumbnail, missionName, missionTiming)
        //addConstraintWithFormat(format: "H:|[v0]|", views: seperateCell)
        addConstraint(NSLayoutConstraint(item: missionStatus, attribute: .left, relatedBy: .equal, toItem: missionName, attribute: .right, multiplier: 1, constant: 0))
        addConstraintWithFormat(format: "H:[v0(50)]", views: missionStatus)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension UIView{
    func addConstraintWithFormat(format: String, views:UIView...){
        var viewsDictionary = [String: UIView]()
        for(index, view) in views.enumerated(){
            let key = "v\(index)"
            view.translatesAutoresizingMaskIntoConstraints = false
            viewsDictionary[key] = view
        }
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
    }
    
    
}
