//
//  MissionWorker.swift
//  RunRRR 2.0
//
//  Created by Jacky Huang on 2018/5/27.
//  Copyright © 2018年 ColdeGarage. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SnapKit

class MissionWorker: NSObject, Worker, UITableViewDelegate, UITableViewDataSource {
    var missionShowList = [MissionsData]()
    var completeMissionList = [MissionsData]()
    var missionShowListTemp = [MissionsData]()
    var completeMissionListTemp = [MissionsData]()
    var missionQueue: UITableView?
    
    private let refreshControl = UIRefreshControl()
    
    init (_ missionQueue: UITableView) {
        super.init()
        self.missionQueue = missionQueue
        
        self.refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        if #available(iOS 10.0, *){
            self.missionQueue?.refreshControl = refreshControl
        } else{
            self.missionQueue?.addSubview(refreshControl)
        }
    }
    
    @objc func refreshData(){
        self.loadMissions()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let missionDetailViewController = MissionsDetailViewController()
        missionDetailViewController.mission = missionShowList[(indexPath.item)]
        UIApplication.shared.keyWindow?.rootViewController?.present(missionDetailViewController, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return missionShowList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "missionCell", for: indexPath) as! MissionTableCell
        
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
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func loadMissions() {
        let userID = UserDefaults.standard.integer(forKey: "RunRRR_UID")
        let token = UserDefaults.standard.string(forKey: "RunRRR_Token")!
        self.missionShowListTemp.removeAll()
        let missionReadParameter: [String:Any] = ["operator_uid":userID,"token":token]
        Alamofire.request("\(CONFIG.API_PREFIX.ROOT)/mission/read", parameters:missionReadParameter).responseJSON{ response in
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
        let userID = UserDefaults.standard.integer(forKey: "RunRRR_UID")
        let token = UserDefaults.standard.string(forKey: "RunRRR_Token")!
        let reportReadParameter = ["operator_uid":userID,"token":token, "uid":userID] as [String : Any]
        Alamofire.request("\(CONFIG.API_PREFIX.ROOT)/report/read",parameters:reportReadParameter).responseJSON{ response in
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
            self.missionQueue!.reloadData()
            
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
        }
    }
}

class MissionTableCell: UITableViewCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupLayout()
        
    }
    let missionPriorityThumbnail: UILabel = {
        let priorityLabel = UILabel()
        
        priorityLabel.text = "主"
        priorityLabel.font = UIFont.systemFont(ofSize: 36)
        priorityLabel.textColor = UIColor.white
        priorityLabel.textAlignment = NSTextAlignment(rawValue: 1)!
        priorityLabel.backgroundColor = UIColor.white
        priorityLabel.layer.borderWidth = CGFloat(0)
        priorityLabel.layer.borderColor = UIColor.white.cgColor
        priorityLabel.layer.cornerRadius = 35
        priorityLabel.layer.masksToBounds = true
        
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
        name.textColor = UIColor.white
        name.layer.borderColor = UIColor.white.cgColor
        name.layer.borderWidth = CGFloat(0)
        name.textAlignment = NSTextAlignment(rawValue: 1)!
        return name
    }()
    let missionTiming: UILabel = {
        let time = UILabel()
        time.text = "23:59"
        time.textAlignment = NSTextAlignment.center
        time.textColor = UIColor.darkGray
        time.layer.borderWidth = CGFloat(0)
        time.layer.borderColor = UIColor.white.cgColor
        time.layer.cornerRadius = 5
        time.layer.masksToBounds = true
        return time
    }()
    let missionStatus: UIImageView = {
        let status = UIImageView()
        
        status.layer.borderWidth = CGFloat(0)
        status.layer.borderColor = UIColor.white.cgColor
        status.layer.cornerRadius = 15
        status.layer.masksToBounds = true
        
        return status
    }()
    
    private func setupLayout() {
        addSubview(missionPriorityThumbnail)
        addSubview(missionName)
        addSubview(missionTiming)
        addSubview(missionStatus)
        
        missionPriorityThumbnail.snp.makeConstraints{(make) in
            make.centerY.equalTo(self.snp.centerY)
            make.height.equalTo(70)
            make.left.equalTo(self).offset(5)
            make.width.equalTo(70)
        }
        missionName.snp.makeConstraints{(make) in
            make.top.equalTo(0)
            make.bottom.equalTo(0)
            make.left.equalTo(missionPriorityThumbnail.snp.right).offset(5)
            make.right.equalTo(missionTiming.snp.left).offset(-5)
        }
        missionTiming.snp.makeConstraints{(make) in
            make.height.equalTo(30)
            make.bottom.equalTo(self).offset(-5)
            make.right.equalTo(self).offset(-5)
            make.left.equalTo(missionName.snp.right).offset(5)
        }
        missionStatus.snp.makeConstraints{(make) in
            make.height.equalTo(30)
            make.bottom.equalTo(self).offset(-5)
            make.width.equalTo(30)
            make.left.equalTo(self).offset(50)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
