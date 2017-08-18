//
//  PhotoImportViewController.swift
//  RunRRR
//
//  Created by Starla on 2017/5/13.
//  Copyright © 2017年 EEECamp. All rights reserved.
//

import UIKit

class PhotoImportViewController: UIViewController {
    
    var importPhoto:UIImage?
    
   
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let availableImage = importPhoto {
            imageView.image = availableImage
        }
        
        
    }
    
    
    @IBAction func goBack(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
}

}
