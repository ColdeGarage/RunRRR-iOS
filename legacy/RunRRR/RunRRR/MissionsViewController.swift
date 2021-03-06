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

class MissionsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, segueViewController {
    @IBOutlet weak var missionStatus: UIImageView!
    var missionShowList = [MissionsData]()
    var completeMissionList = [MissionsData]()
    var missionShowListTemp = [MissionsData]()
    var completeMissionListTemp = [MissionsData]()
    private let refreshControl = UIRefreshControl()
    let userID = UserDefaults.standard.integer(forKey: "RunRRR_UID")
    let token = UserDefaults.standard.string(forKey: "RunRRR_Token")!
    let menuBar : MenuBarBelow = {
        let menubar = MenuBarBelow()
        menubar.currentPage = "Missions"
        return menubar
    }()
    var prevVC:UIViewController?
    lazy var missionCollectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor(red: 230/255, green: 230/255, blue:230/255, alpha: 1)
        cv.delegate = self
        cv.dataSource = self
        return cv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prevVC?.dismiss(animated: false, completion: nil)
        setupCollectionView()
        // Do any additional setup after loading the view.
        missionCollectionView.register(MissionsCell.self, forCellWithReuseIdentifier: "missionsCell")
        missionCollectionView.contentInset = UIEdgeInsetsMake(20, 0, 120, 0)
        if #available(iOS 10.0, *){
            missionCollectionView.refreshControl = refreshControl
        } else{
            missionCollectionView.addSubview(refreshControl)
        }
        // Configure Refresh Control
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        
        self.view.addSubview(menuBar)
        self.view.addConstraintWithFormat(format: "H:|-0-[v0]-0-|", views: menuBar)
        self.view.addConstraintWithFormat(format: "V:[v0(\(self.view.frame.height/6))]-0-|", views: menuBar)
        menuBar.delegate = self
        menuBar.dataSource = self
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
            cell.missionPriorityThumbnail.text = "限"
            cell.missionPriorityThumbnail.textColor = UIColor(red: 255/255, green: 41/255, blue:41/255, alpha: 1)
            cell.backgroundColor = UIColor(red: 255/255, green: 41/255, blue:41/255, alpha: 1)
            
        case "2":
            cell.missionPriorityThumbnail.text = "主"
            cell.missionPriorityThumbnail.textColor = UIColor(red: 75/255, green: 220/255, blue:191/255, alpha: 1)
            cell.backgroundColor = UIColor(red: 75/255, green: 220/255, blue:191/255, alpha: 1)


        case "3":
            cell.missionPriorityThumbnail.text = "支"
            cell.missionPriorityThumbnail.textColor = UIColor(red: 245/255, green: 157/255, blue:52/255, alpha: 1)
            cell.backgroundColor = UIColor(red: 245/255, green: 157/255, blue:52/255, alpha: 1)


        default:
            cell.missionPriorityThumbnail.text = "?"
        }
        //cell.missionPriorityThumbnail.text = missionShow[indexPath.row].type
        switch self.missionShowList[indexPath.row].check {
        case 0:
            //cell.missionStatus.backgroundColor = UIColor.green
            cell.missionStatus.image = UIImage(named: "state_failed")
        case 1: //審核中
            //cell.missionStatus.backgroundColor = UIColor.blue
            cell.missionStatus.image = UIImage(named: "state_waiting")
        case 3:
            //cell.missionStatus.backgroundColor = UIColor.darkGray
            cell.missionStatus.image = UIImage(named: "state_passed")
        default: //未解任務
            cell.missionStatus.image = nil
            cell.missionStatus.backgroundColor = UIColor(red: 230/255, green: 230/255, blue:230/255, alpha: 0)
            //cell.missionName.backgroundColor = UIColor.brown
            //cell.backgroundColor = UIColor.brown
            
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

        self.missionShowListTemp.removeAll()
        let missionReadParameter:[String:Any] = ["operator_uid":self.userID,"token":self.token]
        Alamofire.request("\(Config.HOST):\(Config.PORT)/\(Config.API_PATH)/mission/read",parameters:missionReadParameter).responseJSON{ response in
            
            switch response.result{
            case .success(let value):
                let missionsJson = JSON(value)
                let missions = missionsJson["payload"]["objects"].arrayValue
                
                for mission in missions{
                    guard let mid = mission["mid"].intValue as Int?,
                        let title = mission["title"].stringValue as String?,
                        let content = mission["content"].stringValue as String?,
                        let timeStart = mission["time_start"].stringValue as String?,
                        let timeEnd = mission["time_end"].stringValue as String?,
                        let prize = mission["prize"].intValue as Int?,
                        let clue = mission["clue"].intValue as Int?,
                        let type = mission["class"].stringValue as String?,
                        let score = mission["score"].intValue as Int?,
                        let locationE = mission["location_e"].doubleValue as Double?,
                        let locationN = mission["location_n"].doubleValue as Double?,
                        let missionImageURL = mission["url"].stringValue as String? else {
                            print("parsing mission erreo")
                            return
                    }
                    
                    guard let missionItem = MissionsData(mid:mid,title:title,content:content,timeStart:timeStart,timeEnd:timeEnd,prize:prize,clue:clue,type:type,score:score,locationE:locationE,locationN:locationN,missionImageURL:missionImageURL) else{
                        print("missionItem error!")
                        return
                    }
                    self.missionShowListTemp += [missionItem]
                }
            case .failure(let error):
                print(error)
            }

            self.checkMissionStatus()
        }
    }
    func checkMissionStatus(){
        let reportReadParameter = ["operator_uid":self.userID,"token":self.token, "uid":self.userID] as [String : Any]
        Alamofire.request("\(Config.HOST):\(Config.PORT)/\(Config.API_PATH)/report/read",parameters:reportReadParameter).responseJSON{ response in
            switch response.result{
                
            case .success(let value):
                let missionReportJson = JSON(value)
                let missionReport = missionReportJson["payload"]["objects"].arrayValue
                let serverTime = missionReportJson["server_time"].stringValue.components(separatedBy: "T")[1]
                let serverHour = Int(serverTime.components(separatedBy: ":")[0])!
                let serverMin = Int(serverTime.components(separatedBy: ":")[1])!
                
                for missionStatus in missionReport{
                    let rid = missionStatus["rid"].intValue
                    let mid = missionStatus["mid"].intValue
                    let status = missionStatus["status"].intValue
                    let imageURL = missionStatus["url"].stringValue
                    if let index = self.missionShowListTemp.index(where:{$0.mid == mid}){
                        self.missionShowListTemp[index].imageURL = imageURL
                        self.missionShowListTemp[index].rid = rid
                        //0:審核失敗 1:審核中 2:審核成功 3.未解任務
                        //if mission complete
                        if status == 1 {
                            //                            self.missionShowList[index!].check = 2
                            self.missionShowListTemp[index].check = 3
                            //                            let missionComplete = self.missionShowList[index!]
//                            let missionComplete = self.missionShowListTemp[index]
                            //                            self.missionShowList.remove(at: index!)
//                            self.missionShowListTemp.remove(at: index)
                            //                            self.completeMissionList += [missionComplete]
//                            self.completeMissionListTemp += [missionComplete]
                        }
                        //if mission is reviewing
                        else if status == 0 {
                            //                            self.missionShowList[index!].check = 1
                            self.missionShowListTemp[index].check = 1
                        }
                        else { //mission fail
                            //                            self.missionShowList[index!].check = 0
                            self.missionShowListTemp[index].check = 0
                        }
                    }
                }
                
                var idxToRemove = Set<Int>()

                for idx in 0..<self.missionShowListTemp.count{
                    let timeHour = Int(self.missionShowListTemp[idx].timeEnd.components(separatedBy: ":")[0])!
                    let timeMin = Int(self.missionShowListTemp[idx].timeEnd.components(separatedBy: ":")[1])!
                    if (self.missionShowListTemp[idx].check == 0)||(self.missionShowListTemp[idx].check == 2) { //if reviewing and expired, still need to show
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
                
                self.missionShowListTemp = self.missionShowListTemp
                    .enumerated()
                    .filter {!idxToRemove.contains($0.offset)}
                    .map {$0.element}
                
            case .failure(let error):
                print(error)
            }
                //                self.missionShowList.sort(by: {$0.check < $1.check})
            self.missionShowListTemp.sort(by: {$0.type < $1.type})
            self.missionShowListTemp.sort(by: {$0.check < $1.check})
            
                // self.missionShowList += self.completeMissionList
            self.missionShowList = self.missionShowListTemp
            self.missionCollectionView.reloadData()
            
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
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
    }
    
    func segueToMaps() {
        dismiss(animated: false, completion: nil)
    }
    func segueToBags() {
        let vc = UIStoryboard(name: "Bag", bundle: nil).instantiateViewController(withIdentifier: "BagCollectionViewController") as! BagCollectionViewController
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
    func segueToMissions() {
        
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

class SegueFromLeft: UIStoryboardSegue
{
    override func perform()
    {
        let src = self.source
        let dst = self.destination
        
        src.view.superview?.insertSubview(dst.view, aboveSubview: src.view)
        dst.view.transform = CGAffineTransform(translationX: src.view.frame.size.width, y: 0)
        
        UIView.animate(withDuration: 0.25,
                       delay: 0.0,
                       options: UIViewAnimationOptions.curveEaseInOut,
                       animations: {
                        dst.view.transform = CGAffineTransform(translationX: 0, y: 0)
                        },
                       completion: { finished in
                        src.present(dst, animated: false, completion: nil)
                        }
        )
    }
}
