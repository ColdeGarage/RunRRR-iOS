//
//  MissionsViewController.swift
//  RunRRR
//
//  Created by Jacky Huang on 2017/4/26.
//  Copyright © 2017年 EEECamp. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class MissionsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    var delegate: segueBetweenViewController!
    var missionShowList = [MissionsData]()
    var completeMissionList = [MissionsData]()
    private let refreshControl = UIRefreshControl()
    
    lazy var missionCollectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        cv.delegate = self
        cv.dataSource = self
        return cv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        // Do any additional setup after loading the view.
        missionCollectionView.register(MissionsCell.self, forCellWithReuseIdentifier: "missionsCell")
        missionCollectionView.contentInset = UIEdgeInsetsMake(60, 0, 0, 0)
        if #available(iOS 10.0, *){
            missionCollectionView.refreshControl = refreshControl
        } else{
            missionCollectionView.addSubview(refreshControl)
        }
        // Configure Refresh Control
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        setupMenuBar()
        loadMissions()
    }
    func setupCollectionView(){
        view.addSubview(missionCollectionView)
        view.addConstraintWithFormat(format: "H:|[v0]|", views: missionCollectionView)
        view.addConstraintWithFormat(format: "V:|[v0]|", views: missionCollectionView)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return missionShowList.count

    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
    func loadMissions(){
        Alamofire.request("\(Config.HOST):\(Config.PORT)/\(Config.API_PATH)/mission/read").responseJSON{ response in
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
                self.missionCollectionView.reloadData()
            }
            
        }
        
    }
    func refreshData(){
        self.loadMissions()
        refreshControl.endRefreshing()
    }
    func setupMenuBar(){
        let menuBar : MenuBar = {
            let mb = MenuBar("Mission")
            return mb
        }()
        view.addSubview(menuBar)
        view.addConstraintWithFormat(format: "H:|[v0]|", views: menuBar)
        view.addConstraintWithFormat(format: "V:|-20-[v0(58)]|", views: menuBar)
        (menuBar.arrangedSubviews[0] as! UIButton).addTarget(self, action: #selector(segueToMap), for: .touchUpInside)
        (menuBar.arrangedSubviews[2] as! UIButton).addTarget(self, action: #selector(changeToBag), for: .touchUpInside)
        (menuBar.arrangedSubviews[3] as! UIButton).addTarget(self, action: #selector(changeToMore), for: .touchUpInside)
    }
    func segueToMap(){
        dismiss(animated: true, completion: nil)
    }
    func changeToBag(){
        delegate!.segueToBag()
    }
    func changeToMore(){
        delegate!.segueToMore()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
