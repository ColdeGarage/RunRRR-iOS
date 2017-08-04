//
//  BarcodeViewController.swift
//  RunRRR
//
//  Created by Starla on 2017/5/30.
//  Copyright © 2017年 EEECamp. All rights reserved.
//

import Alamofire
import SwiftyJSON
import UIKit
import Foundation

class BarcodeViewController: UIViewController {

    @IBAction func CancelButtonTapped(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
    @IBOutlet weak var barcodeDisplay: UIImageView!
    let userID = UserDefaults.standard.integer(forKey: "RunRRR_UID")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let userIDString = String(userID)
        barcodeDisplay.image = fromString(string: userIDString)
 
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func fromString(string : String) -> UIImage? {
        
        let data = string.data(using: .ascii)
        let filter = CIFilter(name: "CICode128BarcodeGenerator")
        filter?.setValue(data, forKey: "inputMessage")
        
        return UIImage(ciImage: (filter?.outputImage)!)
    }


    
    

}
