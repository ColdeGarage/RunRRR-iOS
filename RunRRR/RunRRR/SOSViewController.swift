//
//  SOSViewController.swift
//  RunRRR
//
//  Created by Starla on 2017/7/6.
//  Copyright © 2017年 EEECamp. All rights reserved.
//

import UIKit
import Alamofire
import GoogleMaps
import SwiftyJSON
import SWXMLHash
import CoreLocation

class SOSViewController: UIViewController, GMSMapViewDelegate{
    
    let userID = 290//UserDefaults.standard.integer(forKey: "RunRRR_UID")
    let token = 123//UserDefaults.standard.string(forKey: "RunRRR_Token")!
    var validArea:Bool = true
    let manager = CLLocationManager()
    var currentLocatoin : CLLocation!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
    }
    
    
    
    
    
    
    @IBAction func sosButton(_ sender: Any) {
        let currentLocation = self.manager.location!
        let currentLocationLatitude = currentLocation.coordinate.latitude
        let currentLocationLongitude = currentLocation.coordinate.longitude
        
        let sosParameter : Parameters = ["operator_uid":self.userID,"token":self.token, "uid":self.userID, "position_e":currentLocationLongitude, "position_n":currentLocationLatitude, "help_status": 1 as Int]
        Alamofire.request("\(API_URL)/member/callhelp", method: .put, parameters: sosParameter).responseJSON{ response in
            switch(response.result){
            case .success(let value):
                self.sosAlert(titleText: "Received Message", messageText: "Help is on the way, please wait.")
                print("ya")
            case .failure:
                self.sosAlert(titleText: "Error", messageText: "Please try again.")
                print("error")
            }
            
            
           
        }
    }
    
    func sosAlert(titleText : String, messageText: String){
        let alert = UIAlertController(title: titleText, message: messageText, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {(action) in
            alert.dismiss(animated: true, completion: nil)}))
        self.present(alert, animated: true, completion: nil)
    }

}
