//
//  MapWorker.swift
//  RunRRR 2.0
//
//  Created by Jacky Huang on 2018/5/27.
//  Copyright © 2018年 ColdeGarage. All rights reserved.
//

import UIKit
import GoogleMaps
import Alamofire
import SWXMLHash
import SwiftyJSON
import CoreLocation

class MapWorker: Worker {
    var map: GMSMapView
    var view: MapContextView
    var pointSqr: UILabel
    
    var missionShowList = [MissionsData]()
    let manager = CLLocationManager()
    var currentLocatoin : CLLocation!
    var uploadCurrentLocationTimer = Timer()
    var notInAreaWarningTimer = Timer()
    var validArea:Bool = true

    
    init(map: GMSMapView, point: UILabel, target: MapContextView) {
        self.map = map
        self.view = target
        self.pointSqr = point
    }
    
    func loadMapData() {
        self.map.clear()
        self.getMapsBoundary()
        self.getMissionLocations()
        print("Loading Map Data")
    }
    
    func loadLocationData() {
        manager.delegate = self as? CLLocationManagerDelegate
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
        scheduledUploadCurrentLocationTimer()
        scheduledNotInAreaWarning()
    }
    
    func loadPointData() {
        let userID = UserDefaults.standard.integer(forKey: "RunRRR_UID")
        let token = UserDefaults.standard.string(forKey: "RunRRR_Token")
        
        let getPointsPara = ["operator_uid":userID,"token":token!,"uid":userID] as [String : Any]
        
        Alamofire.request("\(CONFIG.API_PREFIX.ROOT)/member/read", method: .get, parameters: getPointsPara).responseJSON{ response in
            print(response)
            switch response.result{
            case .success(let value):
                let jsonData = JSON(value)
                guard let score = jsonData["payload"]["objects"][0]["score"].intValue as Int? else{
                    print("getPoints Error!")
                    return
                }
                self.pointSqr.text = "\(score)"
            // self.pointSquare.text = "\(score)"
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func getMapsBoundary() {
        Alamofire.request("\(CONFIG.API_PREFIX.ROOT)/download/map/boundary.kml").responseData { response in
            
            switch response.result {
            case .success(let value):
                let boundaryXML = SWXMLHash.parse(value)
                let boundaryArray = boundaryXML["kml"]["Document"]["Placemark"]["Polygon"]["outerBoundaryIs"]["LinearRing"]["coordinates"].element?.text
                
                var trimmingBoundaryArray = boundaryArray?.replacingOccurrences(of: "\n", with: "")
                trimmingBoundaryArray = trimmingBoundaryArray?.trimmingCharacters(in: .whitespacesAndNewlines)
                trimmingBoundaryArray = trimmingBoundaryArray?.replacingOccurrences(of: " ", with: "")
                //print(trimmingBoundaryArray)
                let boundaryForGoogleMaps = trimmingBoundaryArray?.components(separatedBy: ",0")
                //print(boundaryForGoogleMaps)
                
                let path = GMSMutablePath()     //Create an path obj and braw a polygon
                for item in boundaryForGoogleMaps!{
                    if !item.isEmpty{
                        let boundaryLocation = item.components(separatedBy: ",")
                        path.add(CLLocationCoordinate2D(latitude: Double(boundaryLocation[1])!, longitude: Double(boundaryLocation[0])!))
                    }
                }
                
                let endPoint = boundaryForGoogleMaps![0].components(separatedBy: ",")
                path.add(CLLocationCoordinate2D(latitude: Double(endPoint[1])!, longitude: Double(endPoint[0])!))
                
                let polygon = GMSPolyline(path: path)
                polygon.map = self.map   //Put the polygon on the map
                polygon.strokeColor = UIColor(red: 243/255, green: 88/255, blue: 82/255, alpha: 1)
                polygon.strokeWidth = 5
                break
            case .failure(let error):
                print(error)
            }
            
        }
    }
    
    private func getMissionLocations() {
        var missionListTemp = [MissionsData]()
        var completeMissionListTemp = [MissionsData]()
        let userID = UserDefaults.standard.integer(forKey: "RunRRR_UID")
        let token = UserDefaults.standard.string(forKey: "RunRRR_Token")
        let missionPara = ["operator_uid": userID, "token": token!] as [String : Any]
        Alamofire.request("\(CONFIG.API_PREFIX.ROOT)/mission/read", method: .get, parameters:missionPara
            ).responseJSON{ response in
                
                switch response.result{
                    
                case .success(let value):
                    print(value)
                    let missionJson = JSON(value)
                    let missionObjects = missionJson["payload"]["objects"].arrayValue
                    guard let serverTime = missionJson["server_time"].stringValue.components(separatedBy: "T")[1] as String? else{
                        return
                    }
                    //let serverHour = 7
                    //let serverMin = 0
                    guard let serverHour = Int(serverTime.components(separatedBy: ":")[0]) else {
                        return
                    }
                    guard let serverMin = Int(serverTime.components(separatedBy: ":")[1]) else {
                        return
                    }
                    
                    for item in missionObjects{
                        
                        print(item)
                        guard let timeEnd = item["time_end"].stringValue as String?,
                            let timeWithoutDate = timeEnd.components(separatedBy: "T")[1] as String?,
                            let timeHour = Int(timeWithoutDate.components(separatedBy: ":")[0]),
                            let timeMin = Int(timeWithoutDate.components(separatedBy: ":")[1]),
                            
                            let locationE = item["location_e"].doubleValue as Double?,
                            let locationN = item["location_n"].doubleValue as Double?,
                            let title = item["title"].stringValue as String? else{
                                //nil
                                return
                        }
                        
                        
                        if locationE != 0 && locationN != 0 {
                            if timeHour > serverHour {
                                let position = CLLocationCoordinate2D(latitude: locationN, longitude: locationE)
                                let marker = GMSMarker(position:position)
                                marker.title = title
                                marker.map = self.map
                            }else if (timeHour == serverHour) && (timeMin > serverMin){
                                let position = CLLocationCoordinate2D(latitude: locationN, longitude: locationE)
                                let marker = GMSMarker(position:position)
                                marker.title = title
                                marker.map = self.map
                            }
                        }
                    }
                case .failure(let error):
                    print(error)
                }
        }
        map.clear()

        let missionReadParameter = ["operator_uid":userID,"token":token!] as [String : Any]
        
        Alamofire.request("\(CONFIG.API_PREFIX.ROOT)/mission/read",parameters:missionReadParameter).responseJSON{ response in
            
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
                        let missionImageURL = mission["url"].stringValue as String? else{
                            //nil
                            return
                    }
                    
                    guard let missionItem = MissionsData(mid:mid,title:title,content:content,timeStart:timeStart,timeEnd:timeEnd,prize:prize,clue:clue,type:type,score:score,locationE:locationE,locationN:locationN,missionImageURL:missionImageURL) else{
                        //nil
                        print("mission error")
                        return
                    }
                    missionListTemp += [missionItem]
                    //self.missionShowList += [missionItem]
                }
            case .failure(let error):
                print(error)
            }
            
            //            self.missionShowList.sort(by: {$0.type < $1.type})
            
            
            let reportReadParameter = ["operator_uid":userID,"token":token!, "uid":userID] as [String : Any]
            Alamofire.request("\(CONFIG.API_PREFIX.ROOT)/report/read",parameters:reportReadParameter).responseJSON{ response in
                switch response.result{
                    
                case .success(let value):
                    let missionReportJson = JSON(value)
                    //print(missionReportJson.description)
                    guard let missionReport = missionReportJson["payload"]["objects"].arrayValue as Array?,
                        let serverTime = missionReportJson["server_time"].stringValue.components(separatedBy: "T")[1] as String? else {
                            print("missionReport error!")
                            return
                    }
                    //let serverHour = 7
                    //let serverMin = 0
                    guard let serverHour = Int(serverTime.components(separatedBy: ":")[0]),
                        let serverMin = Int(serverTime.components(separatedBy: ":")[1]) else {
                            print("serverTime error!")
                            return
                    }
                    //filter the complete mission to the button
                    for missionStatus in missionReport{
                        //let rid = missionStatus["rid"].intValue
                        let mid = missionStatus["mid"].intValue
                        let status = missionStatus["status"].intValue
                        
                        if let index = missionListTemp.index(where:{$0.mid == mid}){
                            
                            //0:審核失敗 1:審核中 2:審核成功 3.未解任務
                            //if mission complete
                            if status == 1 {
                                missionListTemp[index].check = 3
                            }
                                //if mission is reviewing
                            else if status == 0 {
                                missionListTemp[index].check = 1
                            }
                            else { //mission fail
                                missionListTemp[index].check = 0
                                
                            }
                        }
                    }
                    
                    //filter out the fail mission
                    
                    var idxToRemove = Set<Int>()
                    
                    //                   for idx in 0..<self.missionShowList.count{
                    for idx in 0..<missionListTemp.count{
                        let timeHour = Int(missionListTemp[idx].timeEnd.components(separatedBy: ":")[0])!
                        let timeMin = Int(missionListTemp[idx].timeEnd.components(separatedBy: ":")[1])!
                        if (missionListTemp[idx].check != 1) { //if reviewing and expired, still need to show
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
                    missionListTemp = missionListTemp
                        .enumerated()
                        .filter {!idxToRemove.contains($0.offset)}
                        .map {$0.element}
                    
                case .failure(let error):
                    print(error)
                }
                
                for mission in missionListTemp{
                    let locationE = mission.locationE
                    let locationN = mission.locationN
                    let position = CLLocationCoordinate2D(latitude: locationN, longitude: locationE)
                    let marker = GMSMarker(position:position)
                    marker.title = mission.title
                    marker.map = self.map
                }
                self.missionShowList = missionListTemp
            }
        }
    }
    
    func scheduledUploadCurrentLocationTimer(){
        self.uploadCurrentLocationTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.uploadCurrentLocation), userInfo: self.manager, repeats: true)
    }
    func scheduledNotInAreaWarning(){
        self.uploadCurrentLocationTimer = Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(self.notInAreaWarning), userInfo: self.manager, repeats: true)
    }
    
    @objc func uploadCurrentLocation(){
        let currentLocation = self.manager.location!
        let currentLocationLatitude = currentLocation.coordinate.latitude
        let currentLocationLongitude = currentLocation.coordinate.longitude
        let userID = UserDefaults.standard.integer(forKey: "RunRRR_UID")
        let token = UserDefaults.standard.integer(forKey: "RunRRR_Token")
        
        let currentLocationPara : [String:Any] = ["operator_uid":userID,"token":token,"uid":userID, "position_e":currentLocationLongitude, "position_n":currentLocationLatitude]
        
        Alamofire.request("\(CONFIG.API_PREFIX.ROOT)/member/update", method: .put, parameters: currentLocationPara).responseJSON{ response in
            //print(response.timeline)
            //print(response)
            switch response.result{
                
            case .success(let value):
                let memberUpdateInfo = JSON(value)
                //print(memberUpdateInfo)
                guard let memberValidArea = memberUpdateInfo["payload"]["valid_area"].bool else{
                    return
                }
                self.validArea = memberValidArea
                //print(self.validArea)
            //print(self.validArea)
            case .failure(let error):
                print(error)
            }
        }
        
    }
    @objc func notInAreaWarning(){
        if self.validArea == false{
            let ac = UIAlertController(title: "Not in the boundary", message: "趕快回範圍內，不然我會一直警告你", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Behave", style: .default))
            UIApplication.shared.keyWindow?.rootViewController?.present(ac, animated: true, completion: nil)
        }
    }
    
}
