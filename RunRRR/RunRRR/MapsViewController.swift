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


class MapsViewController: UIViewController, GMSMapViewDelegate, segueBetweenViewController{

    @IBOutlet weak var mainMaps: GMSMapView!
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
    //let networkQuality = Reach()
    
    override func viewWillAppear(_ animated: Bool) {
        self.mainMaps.clear()
        getMapsBountry(map: mainMaps)
        getMissionLocations(map: mainMaps)
        getPoints(pointSqr: pointSqr)
        
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
        pointSqr.text! = "10"
        pointSqr.backgroundColor = UIColor(red:250/255, green:250/255, blue:250/255, alpha:1.0)
        pointSqr.layer.masksToBounds = true
        pointSqr.layer.cornerRadius = 8.0
        
        //current location
        manager.delegate = self as? CLLocationManagerDelegate
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
        scheduledUploadCurrentLocationTimer()
        scheduledNotInAreaWarning()
        
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
                
            case .failure(let error):
                print(error)
            }
           
            }
    }
    func getPoints(pointSqr:UILabel){

        let getPointsPara = ["operator_uid":self.userID,"token":self.token,"uid":self.userID] as [String : Any]
        
        Alamofire.request("\(Config.HOST):\(Config.PORT)/\(Config.API_PATH)/member/read", method: .get, parameters: getPointsPara).responseJSON{ response in

            switch response.result{
                case .success(let value):
                    let jsonData = JSON(value)
                    let score = jsonData["payload"]["objects"]["score"].intValue.description
                    pointSqr.text = score
                case .failure(let error):
                    print(error)
            }
        }
    }
    
    func getMissionLocations(map:GMSMapView){

        /*let missionPara = ["operator_uid":self.userID]
        Alamofire.request("\(Config.HOST):\(Config.PORT)/\(Config.API_PATH)/mission/read", method: .get, parameters:missionPara
            ).responseJSON{ response in

            switch response.result{
            
            case .success(let value):
                let missionJson = JSON(value)
                let missionObjects = missionJson["payload"]["objects"].arrayValue
                //let serverTime = missionReportJson["server_time"].stringValue.components(separatedBy: "T")[1]
                let serverHour = 7
                let serverMin = 0
                //let serverHour = Int(serverTime.components(separatedBy: ":")[0])!
                //let serverMin = Int(serverTime.components(separatedBy: ":")[1])!
                
                for item in missionObjects{

                    print(item)
                    let timeEnd = item["time_end"].stringValue
                    let timeWithoutDate = timeEnd.components(separatedBy: "T")[1]
                    let timeHour = Int(timeWithoutDate.components(separatedBy: ":")[0])!
                    let timeMin = Int(timeWithoutDate.components(separatedBy: ":")[1])!
                    
                    let locationE = item["location_e"].doubleValue
                    let locationN = item["location_n"].doubleValue
                    let title = item["title"].stringValue
                    
                    
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
        }*/
        map.clear()
        missionShowList.removeAll()
        completeMissionList.removeAll()

        let missionReadParameter = ["operator_uid":self.userID,"token":self.token] as [String : Any]

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
                        //let rid = missionStatus["rid"].intValue
                        let mid = missionStatus["mid"].intValue
                        let status = missionStatus["status"].intValue
                        //let imageURL = missionStatus["url"].stringValue
                        let index = self.missionShowList.index(where:{$0.mid == mid})
                        
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

                    var idxToRemove = Set<Int>()

                    for idx in 0...self.missionShowList.count-1{
                        let timeHour = Int(self.missionShowList[idx].timeEnd.components(separatedBy: ":")[0])!
                        let timeMin = Int(self.missionShowList[idx].timeEnd.components(separatedBy: ":")[1])!
                        //if self.missionShowList[idx].check != 0 { //if reviewing and expired, still need to show
                            if timeHour < serverHour{
                                idxToRemove.insert(idx)
                            }
                            else if timeHour == serverHour{
                                if timeMin < serverMin{
                                    idxToRemove.insert(idx)
                                }
                            }
                        //}
                    }
                    self.missionShowList = self.missionShowList
                        .enumerated()
                        .filter {!idxToRemove.contains($0.offset)}
                        .map {$0.element}

                case .failure(let error):
                    print(error)
                }
                
                for mission in self.missionShowList{
                    let locationE = mission.locationE
                    let locationN = mission.locationN
                    let position = CLLocationCoordinate2D(latitude: locationN, longitude: locationE)
                    let marker = GMSMarker(position:position)
                    marker.title = mission.title
                    marker.map = map
                }
            }
            
        }
        

        
    }
    
    
    func scheduledUploadCurrentLocationTimer(){
        uploadCurrentLocationTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(MapsViewController.uploadCurrentLocation), userInfo: self.manager, repeats: true)
    }
    func scheduledNotInAreaWarning(){
        uploadCurrentLocationTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(MapsViewController.notInAreaWarning), userInfo: self.manager, repeats: true)
    }
    
    func uploadCurrentLocation(){
        let currentLocation = self.manager.location!
        let currentLocationLatitude = currentLocation.coordinate.latitude
        let currentLocationLongitude = currentLocation.coordinate.longitude
        
        let currentLocationPara : [String:Any] = ["operator_uid":self.userID,"token":self.token,"uid":self.userID, "position_e":currentLocationLongitude, "position_n":currentLocationLatitude]
        
        Alamofire.request("\(Config.HOST):\(Config.PORT)/\(Config.API_PATH)/member/update", method: .put, parameters: currentLocationPara).responseJSON{ response in
            //print(response.timeline)
            switch response.result{
                
            case .success(let value):
                let memberUpdateInfo = JSON(value)
                //print(memberUpdateInfo)
                self.validArea = memberUpdateInfo["payload"]["valid_area"].boolValue
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
    
    @IBAction func missionButtonTapped(_ sender: Any) {
        let vc = UIStoryboard(name: "Missions", bundle: nil).instantiateViewController(withIdentifier: "MissionsViewController") as! MissionsViewController
        vc.delegate = self
        self.present(vc, animated: false, completion: nil)
    }
    @IBAction func bagButtonTapped(_ sender: Any) {
        let vc = UIStoryboard(name: "Bag", bundle: nil).instantiateViewController(withIdentifier: "BagCollectionViewController") as! BagCollectionViewController
        vc.delegate = self
        self.present(vc, animated: false, completion: nil)
    }
    func segueToBag(){
        self.dismiss(animated: false, completion: nil)
        let vc = UIStoryboard(name: "Bag", bundle: nil).instantiateViewController(withIdentifier: "BagCollectionViewController") as! BagCollectionViewController
        vc.delegate = self
        self.present(vc, animated: false, completion: nil)
    }
    func segueToMore(){
        self.dismiss(animated: false, completion: nil)
        let vc = UIStoryboard(name: "More", bundle: nil).instantiateViewController(withIdentifier: "MoreNavigator") as! UINavigationController
        //print(vc.description)
        self.present(vc, animated: false, completion: nil)
    }
    func segueToMission(){
        self.dismiss(animated: false, completion: nil)
        let vc = UIStoryboard(name: "Missions", bundle: nil).instantiateViewController(withIdentifier: "MissionsViewController") as! MissionsViewController
        vc.delegate = self
        self.present(vc, animated: false, completion: nil)
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    //override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    //}

}

protocol segueBetweenViewController {
    func segueToBag()
    func segueToMore()
    func segueToMission()
}


