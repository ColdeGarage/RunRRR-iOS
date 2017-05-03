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
    let userID = UserDefaults.standard.integer(forKey: "RunRRR_UID")
    let manager = CLLocationManager()
    var currentLocatoin : CLLocation!
    var uploadCurrentLocationTimer = Timer()
    //let networkQuality = Reach()
    
    
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
        getMapsBountry(map: mainMaps)
        getMissionLocations(map: mainMaps)
        getPoints(pointSqr: pointSqr)
        
        //current location
        manager.delegate = self as? CLLocationManagerDelegate
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
        //uploadCurrentLocation(manager: self.manager)
        scheduledUploadCurrentLocationTimer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func getMapsBountry(map: GMSMapView){
        Alamofire.request("file:///Users/yi-chun/Desktop/RunRRR/RunRRR/TestingJson/mapBoundary.xml").responseData { response in
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
        let getPointsPara = ["operator_uid":self.userID,"uid":self.userID]
        
        Alamofire.request("http://coldegarage.tech:8081/api/v1/member/read", method: .get, parameters: getPointsPara).responseJSON{ response in
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
        let missionPara = ["operator_uid":self.userID]
        Alamofire.request("\(Config.HOST):\(Config.PORT)/\(Config.API_PATH)/mission/read", method: .get, parameters:missionPara
            ).responseJSON{ response in
            switch response.result{
            
            case .success(let value):
                let missionJson = JSON(value)
                let missionObjects = missionJson["payload"]["objects"].arrayValue
                
                
                for item in missionObjects{
                    let locationE = item["location_e"].doubleValue
                    let locationN = item["location_n"].doubleValue
                    let title = item["title"].stringValue
                    
                    if locationE != 0 && locationN != 0 {
                        let position = CLLocationCoordinate2D(latitude: locationN, longitude: locationE)
                        let marker = GMSMarker(position:position)
                        marker.title = title
                        marker.map = map
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    
    func scheduledUploadCurrentLocationTimer(){
        uploadCurrentLocationTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(MapsViewController.uploadCurrentLocation), userInfo: self.manager, repeats: true)
    }
    func uploadCurrentLocation(){
        let currentLocation = self.manager.location!
        let currentLocationLatitude = currentLocation.coordinate.latitude
        let currentLocationLongitude = currentLocation.coordinate.longitude
        //print(currentLocationLatitude)
        //print(currentLocationLongitude)
        //print(self.userID)
        //print(networkQuality.connectionStatus())
        
        let currentLocationPara : [String:Any] = ["operator_uid":self.userID,"uid":self.userID, "position_e":currentLocationLongitude, "position_n":currentLocationLatitude]
        Alamofire.request("http://coldegarage.tech:8081/api/v1/member/update", method: .put, parameters: currentLocationPara).responseJSON{ response in
            print(response.timeline)
            switch response.result{
                
            case .success(let value):
                let memberUpdateInfo = JSON(value)
                let brea = memberUpdateInfo["brea"].intValue
                if brea != 0 {
                    print("Something wrong")
                }
            case .failure(let error):
                print(error)
            }
        }

    }
    @IBAction func missionButtonTapped(_ sender: Any) {
        let vc = UIStoryboard(name: "Missions", bundle: nil).instantiateViewController(withIdentifier: "MissionsViewController") as! MissionsViewController
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
    @IBAction func bagButtonTapped(_ sender: Any) {
        let vc = UIStoryboard(name: "Bag", bundle: nil).instantiateViewController(withIdentifier: "BagCollectionViewController") as! BagCollectionViewController
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
    func segueToBag(){
        self.dismiss(animated: true, completion: nil)
        let vc = UIStoryboard(name: "Bag", bundle: nil).instantiateViewController(withIdentifier: "BagCollectionViewController") as! BagCollectionViewController
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
    func segueToMore(){
        self.dismiss(animated: true, completion: nil)
        let vc = UIStoryboard(name: "More", bundle: nil).instantiateViewController(withIdentifier: "MoreNavigator") as! UINavigationController
        self.present(vc, animated: true, completion: nil)
    }
    func segueToMission(){
        self.dismiss(animated: true, completion: nil)
        let vc = UIStoryboard(name: "Missions", bundle: nil).instantiateViewController(withIdentifier: "MissionsViewController") as! MissionsViewController
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
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


