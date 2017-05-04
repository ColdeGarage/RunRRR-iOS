//
//  MissionsDetailViewController.swift
//  RunRRR
//
//  Created by Starla on 2017/4/16.
//  Copyright © 2017年 EEECamp. All rights reserved.
//

import UIKit

class MissionsDetailViewController: UIViewController {

    
    @IBOutlet weak var priorityLabel: PriorityLabel!
    @IBAction func exitMissionDetailButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var missionContentTextView: UITextView!
    @IBOutlet weak var missionNameLabel: UILabel!
    var mission : MissionsData?
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMissionDetail()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    
    }
    private func setupMissionDetail(){
        if let missionPriority = mission?.type{
            switch(missionPriority){
            case "1":
                priorityLabel.text = "緊"
            case "2":
                priorityLabel.text = "主"
            case "3":
                priorityLabel.text = "支"
            default:
                priorityLabel.text = "?"
            }
        }
        
        
        missionNameLabel.text = mission?.title
        missionContentTextView.text = mission?.content
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




