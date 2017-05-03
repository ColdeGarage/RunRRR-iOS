//
//  MissionsDetailViewController.swift
//  RunRRR
//
//  Created by Starla on 2017/4/16.
//  Copyright © 2017年 EEECamp. All rights reserved.
//

import UIKit

class MissionsDetailViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    
    }
    

}


@IBDesignable class CloseButton: UIButton {
    @IBInspectable var CornerRadius: CGFloat = 0{
        didSet{
            self.layer.cornerRadius = CornerRadius
        }
    }
    @IBInspectable var BorderWidth: CGFloat = 0{
        didSet{
            self.layer.borderWidth = BorderWidth
        }
    }
    @IBInspectable var BorderColor: UIColor = UIColor.clear{
        didSet{
            self.layer.borderColor = BorderColor.cgColor
        }
    }
    
}


@IBDesignable class PriorityLabel: UILabel {
    @IBInspectable var CornerRadius: CGFloat = 0{
        didSet{
            self.layer.cornerRadius = CornerRadius
        }
    }
    @IBInspectable var BorderWidth: CGFloat = 0{
        didSet{
            self.layer.borderWidth = BorderWidth
        }
    }
    @IBInspectable var BorderColor: UIColor = UIColor.clear{
        didSet{
            self.layer.borderColor = BorderColor.cgColor
        }
    }
    
}




@IBDesignable class CameraButton: UIButton {
    @IBInspectable var CornerRadius: CGFloat = 0{
        didSet{
            self.layer.cornerRadius = CornerRadius
        }
    }
    @IBInspectable var BorderWidth: CGFloat = 0{
        didSet{
            self.layer.borderWidth = BorderWidth
        }
    }
    @IBInspectable var BorderColor: UIColor = UIColor.clear{
        didSet{
            self.layer.borderColor = BorderColor.cgColor
        }
    }
    
}




