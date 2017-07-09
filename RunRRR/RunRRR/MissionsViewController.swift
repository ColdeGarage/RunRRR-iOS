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
    let userID = UserDefaults.standard.integer(forKey: "RunRRR_UID")
    let token = UserDefaults.standard.string(forKey: "RunRRR_Token")!
    
    lazy var missionCollectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        cv.delegate = self
        cv.dataSource = self
        return cv
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        loadMissions()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        // Do any additional setup after loading the view.
        missionCollectionView.register(MissionsCell.self, forCellWithReuseIdentifier: "missionsCell")
        missionCollectionView.contentInset = UIEdgeInsetsMake(80, 0, 0, 0)
        if #available(iOS 10.0, *){
            missionCollectionView.refreshControl = refreshControl
        } else{
            missionCollectionView.addSubview(refreshControl)
        }
        // Configure Refresh Control
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        setupMenuBar()
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
        case 0:
            cell.missionStatus.backgroundColor = UIColor.green
        case 1: //審核中
            cell.missionStatus.backgroundColor = UIColor.blue
        case 2:
            cell.missionStatus.backgroundColor = UIColor.darkGray
        default: //未解任務
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
        missionShowList.removeAll()
        completeMissionList.removeAll()
        let missionReadParameter:[String:Any] = ["operator_uid":self.userID,"token":self.token]
        Alamofire.request("\(Config.HOST):\(Config.PORT)/\(Config.API_PATH)/mission/read",parameters:missionReadParameter).responseJSON{ response in

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
                    let missionImageURL = mission["url"].stringValue
                    
                    guard let missionItem = MissionsData(mid:mid,title:title,content:content,timeStart:timeStart,timeEnd:timeEnd,price:price,clue:clue,type:type,score:score,locationE:locationE,locationN:locationN,missionImageURL:missionImageURL) else{
                        fatalError("Unable to load missionItem")
                    }
                    self.missionShowList += [missionItem]
                }
            case .failure(let error):
                print(error)
            }
            self.missionShowList.sort(by: {$0.type < $1.type})
            
            let reportReadParameter = ["operator_uid":self.userID,"token":self.token, "uid":self.userID] as [String : Any]
            Alamofire.request("\(Config.HOST):\(Config.PORT)/\(Config.API_PATH)/report/read",parameters:reportReadParameter).responseJSON{ response in
                switch response.result{
                    
                case .success(let value):
                    let missionReportJson = JSON(value)
                    //print(missionReportJson.description)
                    let missionReport = missionReportJson["payload"]["objects"].arrayValue
                    let serverTime = missionReportJson["server_time"].stringValue.components(separatedBy: "T")[1]
                    let serverHour = 7
                    let serverMin = 0
                    //print(missionReport.description)
                    //let serverHour = Int(serverTime.components(separatedBy: ":")[0])!
                    //let serverMin = Int(serverTime.components(separatedBy: ":")[1])!
                    //filter the complete mission to the button
                    for missionStatus in missionReport{
                        let rid = missionStatus["rid"].intValue
                        let mid = missionStatus["mid"].intValue
                        let status = missionStatus["status"].intValue
                        let imageURL = missionStatus["url"].stringValue
                        let index = self.missionShowList.index(where:{$0.mid == mid})
                        
                        self.missionShowList[index!].imageURL = imageURL
                        self.missionShowList[index!].rid = rid
                        //0:審核失敗 1:審核中 2:審核成功 3.未解任務
                        //if mission complete
                        if status == 1 {
                            self.missionShowList[index!].check = 2
                            let missionComplete = self.missionShowList[index!]
                            self.missionShowList.remove(at: index!)
                            self.completeMissionList += [missionComplete]
                        }
                        //if mission is reviewing
                        else if status == 0 {
                            self.missionShowList[index!].check = 1
                        }
                        else { //mission fail
                            self.missionShowList[index!].check = 0
                        }
                    }
                    
                    //filter out the fail mission
                    /*var idxToRemove = Set<Int>()
                    
                   /*for idx in 0...self.missionShowList.count-1{
                        let timeHour = Int(self.missionShowList[idx].timeEnd.components(separatedBy: ":")[0])!
                        let timeMin = Int(self.missionShowList[idx].timeEnd.components(separatedBy: ":")[1])!
                        if self.missionShowList[idx].check != 0 { //if reviewing and expired, still need to show
                            if timeHour < serverHour{
                                idxToRemove.insert(idx)
                            }
                            else if timeHour == serverHour{
                                if timeMin < serverMin{
                                    idxToRemove.insert(idx)
                                }
                            }
                        }
                    }*/
                    self.missionShowList = self.missionShowList
                        .enumerated()
                        .filter {!idxToRemove.contains($0.offset)}
                        .map {$0.element}*/
                case .failure(let error):
                    print(error)
                }
                self.missionShowList.sort(by: {$0.check < $1.check})
                self.missionShowList += self.completeMissionList
                self.missionCollectionView.reloadData()
            }
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowMissionDetail", sender: collectionView.cellForItem(at: indexPath))
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch(segue.identifier ?? ""){
            case "ShowMissionDetail":
            let missionDetailViewController = segue.destination as? MissionsDetailViewController
            let selectedMissionCell = sender as? MissionsCell
            let indexPath = missionCollectionView.indexPath(for: selectedMissionCell!)
            
            let selectedMission = missionShowList[(indexPath?.item)!]
            missionDetailViewController?.mission = selectedMission
        default: break
            
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
