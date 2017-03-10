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

class MapsViewController: UIViewController {

    @IBOutlet weak var mainMaps: GMSMapView!
    @IBOutlet weak var pointSqr: UILabel!
    
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
        pointSqr.text! = "0"
        pointSqr.backgroundColor = UIColor(red:250/255, green:250/255, blue:250/255, alpha:1.0)
        pointSqr.layer.masksToBounds = true
        pointSqr.layer.cornerRadius = 8.0
        getMapsBountry(map: mainMaps)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func getMapsBountry(map: GMSMapView){
        Alamofire.request("file:///Users/jackyhuang/RunRRProject/RunRRR/TestingJson/boundary.json").responseJSON { response in
            //print(response.request)  // original URL request
            //print(response.response) // HTTP URL response
            //print(response.data)     // server data
            //print(response.result)   // result of response serialization
            
            switch response.result {
                case .success(let value):
                    let jsonData = JSON(value)
                    let valid = jsonData["brea"].int
                    
                    if (valid == 1){
                        let dataX = jsonData["boundary"]["x"].arrayValue
                        let dataY = jsonData["boundary"]["y"].arrayValue
                    
                        let path = GMSMutablePath()     //Create an path obj and braw a polygon
                
                        for i in 0...dataX.count-1{
                            path.add(CLLocationCoordinate2D(latitude: dataY[i].doubleValue, longitude: dataX[i].doubleValue))
                        }
                
                        path.add(CLLocationCoordinate2D(latitude: dataY[0].doubleValue, longitude: dataX[0].doubleValue))
                        let polygon = GMSPolyline(path: path)
                        polygon.map = map   //Put the polygon on the map
                    }
                    else{
                        print("Boundary drawing is fail, please check your network")
                    }
                
                case .failure(let error):
                    print(error)
            }
        }
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
