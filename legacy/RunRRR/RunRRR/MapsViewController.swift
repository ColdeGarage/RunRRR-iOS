//
//  MapsViewController.swift
//  RunRRR
//
//  Created by Yi-Chun on 2017/3/4.
//  Copyright © 2017年 EEECamp. All rights reserved.
//

import UIKit
import GoogleMaps
import Alamofire
import SwiftyJSON
import SWXMLHash
import CoreLocation


class MapsViewController: UIViewController, GMSMapViewDelegate, segueViewController{

    let mainMaps = GMSMapView()
    @IBOutlet weak var pointSqr: UILabel!
    var missionShowList = [MissionsData]()
    var completeMissionList = [MissionsData]()
    let userID = UserDefaults.standard.integer(forKey: "RunRRR_UID")
    let token = UserDefaults.standard.string(forKey: "RunRRR_Token")!
    var validArea:Bool = true
    let manager = CLLocationManager()
    
    var currentLocatoin : CLLocation!
    var uploadCurrentLocationTimer = Timer()
    var notInAreaWarningTimer = Timer()
    let menuBar : MenuBarBelow = {
        let menubar = MenuBarBelow()
        menubar.currentPage = "Maps"
        return menubar
    }()
    let shadowView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
    //let networkQuality = Reach()
    let pointSquare : UILabel = {
        let label = UILabel()
        label.text = "0"
        label.textAlignment = .left
        label.layer.borderWidth = 0
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 48)
        return label
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        self.mainMaps.clear()
        getMapsBountry(map: mainMaps)
        getMissionLocations(map: mainMaps)
        getPoints(pointSqr: self.pointSquare)
    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        let camera = GMSCameraPosition.camera(withLatitude: 24.794589, longitude: 120.993393, zoom: 15.0)
        //let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        
        mainMaps.camera = camera
        // Do any additional setup after loading the view.
        
        mainMaps.isMyLocationEnabled = true
        mainMaps.settings.myLocationButton = true
        
        // Enable the myLocationButton
        mainMaps.settings.zoomGestures = true
        mainMaps.layer.cornerRadius = 10
        mainMaps.layer.masksToBounds = true
        
//        shadowView.backgroundColor = UIColor.black
        shadowView.layer.shadowColor = UIColor.darkGray.cgColor
        shadowView.layer.shadowOpacity = 1
        shadowView.layer.shadowOffset = CGSize.zero
        shadowView.layer.shadowRadius = 5
        
        shadowView.addSubview(mainMaps)
        
        self.view.addSubview(shadowView)
        
        view.backgroundColor = UIColor(red: 230/255, green: 230/255, blue:230/255, alpha: 1)
        self.view.addConstraintWithFormat(format: "H:|-8-[v0]-8-|", views: shadowView)
        self.view.addConstraintWithFormat(format: "V:[v0(\(self.view.frame.height*19/30))]-\(self.view.frame.height/6+20)-|", views: shadowView)
        shadowView.addConstraintWithFormat(format: "H:|[v0]|", views: mainMaps)
        shadowView.addConstraintWithFormat(format: "V:|[v0]|", views: mainMaps)
        let pointLabel : UILabel = {
            let label = UILabel()
            label.text = "POINT"
            label.textColor = UIColor.gray
            return label
        }()
        self.view.addSubview(pointLabel)
        
        
        
        self.view.addSubview(pointSquare)
        self.view.addConstraintWithFormat(format: "H:|-\(self.view.frame.width/3.5)-[v0(60)]-[v1]-\(self.view.frame.width/8)-|", views: pointLabel,pointSquare)
        self.view.addConstraintWithFormat(format: "V:|-40-[v0(30)]", views: pointLabel)
        self.view.addConstraintWithFormat(format: "V:|-40-[v0(50)]", views: pointSquare)

                
        //current location
        manager.delegate = self as? CLLocationManagerDelegate
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
        scheduledUploadCurrentLocationTimer()
        scheduledNotInAreaWarning()
        menuBar.delegate = self
        menuBar.dataSource = self
        self.view.addSubview(menuBar)
        self.view.addConstraintWithFormat(format: "H:|[v0]|", views: menuBar)
        self.view.addConstraintWithFormat(format: "V:[v0(\(self.view.frame.height/6))]-0-|", views: menuBar)
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func getMapsBountry(map: GMSMapView){
        Alamofire.request("\(Config.HOST):\(Config.PORT)/\(Config.API_PATH)/download/map/boundary.kml").responseData { response in
            //print(response.request)  // original URL request
            //print(response.response) // HTTP URL response
            //print(response.data)     // server data
            //print(response.result.value)   // result of response serialization
            
            switch response.result{
            case .success(let value):
                let boundaryXML = SWXMLHash.parse(value)
                let boundaryArray = boundaryXML["kml"]["Document"]["Folder"]["Placemark"]["Polygon"]["outerBoundaryIs"]["LinearRing"]["coordinates"].element?.text
                
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
                polygon.map = map   //Put the polygon on the map
                polygon.strokeColor = UIColor(red: 243/255, green: 88/255, blue: 82/255, alpha: 1)
                polygon.strokeWidth = 5
                
            case .failure(let error):
                print(error)
            }
           
            }
    }
    func getPoints(pointSqr:UILabel){

        let getPointsPara = ["operator_uid":self.userID,"token":self.token,"uid":self.userID] as [String : Any]
        
        Alamofire.request("\(Config.HOST):\(Config.PORT)/\(Config.API_PATH)/member/read", method: .get, parameters: getPointsPara).responseJSON{ response in
            print(response)
            switch response.result{
                case .success(let value):
                    let jsonData = JSON(value)
                    guard let score = jsonData["payload"]["objects"][0]["score"].intValue as Int? else{
                        print("getPoints Error!")
                        return
                    }
                    pointSqr.text = "\(score)"
                   // self.pointSquare.text = "\(score)"
                case .failure(let error):
                    print(error)
            }
        }
    }
    
    func getMissionLocations(map:GMSMapView){
        var missionListTemp = [MissionsData]()
        var completeMissionListTemp = [MissionsData]()
        let missionPara = ["operator_uid":self.userID]
        Alamofire.request("\(Config.HOST):\(Config.PORT)/\(Config.API_PATH)/mission/read", method: .get, parameters:missionPara
            ).responseJSON{ response in

            switch response.result{
            
            case .success(let value):
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
                            marker.map = map
                        }else if (timeHour == serverHour) && (timeMin > serverMin){
                            let position = CLLocationCoordinate2D(latitude: locationN, longitude: locationE)
                            let marker = GMSMarker(position:position)
                            marker.title = title
                            marker.map = map
                        }
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
        map.clear()
//        missionShowList.removeAll()
//        completeMissionList.removeAll()

        let missionReadParameter = ["operator_uid":self.userID,"token":self.token] as [String : Any]

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
            
            
            let reportReadParameter = ["operator_uid":self.userID,"token":self.token, "uid":self.userID] as [String : Any]
            Alamofire.request("\(Config.HOST):\(Config.PORT)/\(Config.API_PATH)/report/read",parameters:reportReadParameter).responseJSON{ response in
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
                    marker.map = map
                }
                self.missionShowList = missionListTemp
            }
            
        }
        

        
    }
    
    
    func scheduledUploadCurrentLocationTimer(){
        uploadCurrentLocationTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(MapsViewController.uploadCurrentLocation), userInfo: self.manager, repeats: true)
    }
    func scheduledNotInAreaWarning(){
        uploadCurrentLocationTimer = Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(MapsViewController.notInAreaWarning), userInfo: self.manager, repeats: true)
    }
    
    func uploadCurrentLocation(){
        let currentLocation = self.manager.location!
        let currentLocationLatitude = currentLocation.coordinate.latitude
        let currentLocationLongitude = currentLocation.coordinate.longitude
        
        let currentLocationPara : [String:Any] = ["operator_uid":self.userID,"token":self.token,"uid":self.userID, "position_e":currentLocationLongitude, "position_n":currentLocationLatitude]
        
        Alamofire.request("\(Config.HOST):\(Config.PORT)/\(Config.API_PATH)/member/update", method: .put, parameters: currentLocationPara).responseJSON{ response in
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
    func notInAreaWarning(){
        if self.validArea == false{
            let ac = UIAlertController(title: "Not in the boundary", message: "趕快回範圍內，不然我會一直警告你", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Behave", style: .default))
            present(ac, animated: true)
        }
    
    }
    
 /*   @IBAction func missionButtonTapped(_ sender: Any) {
        let vc = UIStoryboard(name: "Missions", bundle: nil).instantiateViewController(withIdentifier: "MissionsViewController") as! MissionsViewController
        vc.delegate = self
        self.present(vc, animated: false, completion: nil)
    }
    @IBAction func bagButtonTapped(_ sender: Any) {
        let vc = UIStoryboard(name: "Bag", bundle: nil).instantiateViewController(withIdentifier: "BagCollectionViewController") as! BagCollectionViewController
        vc.delegate = self
        self.present(vc, animated: false, completion: nil)
    }*/
    
    
    @IBAction func moreButtonTapped(_ sender: Any){
        let vc = UIStoryboard(name: "More", bundle: nil).instantiateViewController(withIdentifier: "MoreViewController") as! MoreViewController
        self.present(vc, animated: false, completion: nil)
    }
    func segueToBags(){
        let vc = UIStoryboard(name: "Bag", bundle: nil).instantiateViewController(withIdentifier: "BagCollectionViewController") as! BagCollectionViewController
        self.present(vc, animated: false, completion: nil)
    }
    func segueToMore(){
        let vc = UIStoryboard(name: "More", bundle: nil).instantiateViewController(withIdentifier: "MoreViewController") as! MoreViewController
        //print(vc.description)
        self.present(vc, animated: false, completion: nil)
    }
    func segueToMissions(){
        let vc = UIStoryboard(name: "Missions", bundle: nil).instantiateViewController(withIdentifier: "MissionsViewController") as! MissionsViewController
        self.present(vc, animated: false, completion: nil)
    }
    func segueToMaps() {
        
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    //override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    //}

}

