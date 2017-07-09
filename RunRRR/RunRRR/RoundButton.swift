//
//  MissionsDetailViewController.swift
//  RunRRR
//
//  Created by Starla on 2017/4/16.
//  Copyright © 2017年 EEECamp. All rights reserved.
//

import UIKit
import ALCameraViewController
import Alamofire
import SwiftyJSON
import SwiftyCam

class MissionsDetailViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var imagePicker: UIImagePickerController!
    let userID = UserDefaults.standard.integer(forKey: "RunRRR_UID")
    let token = UserDefaults.standard.string(forKey: "RunRRR_Token")!
    var mission : MissionsData?
    @IBOutlet weak var showImage: UIImageView!
    @IBOutlet weak var missionImage: UIImageView!
    @IBOutlet weak var priorityLabel: PriorityLabel!
    @IBAction func exitMissionDetailButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var missionContentTextView: UITextView!
    @IBOutlet weak var missionNameLabel: UILabel!
    @IBOutlet weak var cameraButton: CameraButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMissionDetail()
        self.missionImage.contentMode = .scaleAspectFit
        self.showImage.contentMode = .scaleAspectFit
        let parameterSent : Parameters = ["operator_uid":userID, "token":token, "uid":userID]
        Alamofire.request("\(Config.HOST):\(Config.PORT)/\(Config.API_PATH)/member/read", parameters: parameterSent).responseJSON{ response in
            if response.result.isSuccess {
                let statusJson = JSON(response.result.value!)
                let statusArray = statusJson["payload"]["object"].arrayValue
                let userStatus = statusArray[0]["status"].intValue
                    if ( userStatus == 1) {
                        self.cameraButton.isHidden = false
                    }
                    else {
                        self.cameraButton.isHidden = true
                    }
            } else {
            print(response.error!)
            }
        }
    
    
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
        if let remoteImage = mission?.imageURL{
            let imageURL:URLConvertible = "\(Config.HOST):\(Config.PORT)/\(Config.API_PATH)/download/img/" + remoteImage
            //print(imageURL)
            Alamofire.request(imageURL).validate().responseData{ response in
                switch response.result{
                    case .success(let value):
                        let image2Show = UIImage(data:value)!
                        self.showImage.image = image2Show
                    case .failure(let error):
                        print(error)
                }
            }
        }else{
            print("no photo")
        }
 
        if let remoteMissionImage = mission?.missionImageURL{
            print(remoteMissionImage)
            let missionImageURL:URLConvertible = "\(Config.HOST):\(Config.PORT)/\(Config.API_PATH)/download/img/" + remoteMissionImage
            Alamofire.request(missionImageURL).validate().responseData{ response in
                switch response.result{
                    case .success(let value):
                        let missionImage2Show = UIImage(data:value)!
                        self.missionImage.image = missionImage2Show
                    case .failure(let error):
                        print(error)
                }
            
            }
        }else{
            print("No photo mission")
        }
    }
    
    
    @IBAction func choosePhoto(_ sender: Any) {
        if (mission?.check != 1) && (mission?.check != 2){
            let croppingEnabled = false
            let cameraViewController = ALCameraViewController.CameraViewController(croppingEnabled: croppingEnabled) { [weak self] image, asset in
                // Do something with your image here.
                // If cropping is enabled this image will be the cropped version
                let jpegCompressionQuality: CGFloat = 0.1
                let imageBase64 = UIImageJPEGRepresentation(image!, jpegCompressionQuality)?.base64EncodedString()
                if let mid = self?.mission?.mid{
                    var urlReport:URLConvertible
                    var methodReport:HTTPMethod
                    
                    if self?.mission?.check == 0 {  //失敗任務
                        urlReport = "\(Config.HOST):\(Config.PORT)/\(Config.API_PATH)/report/edit"
                        methodReport = Alamofire.HTTPMethod.put
                        //print("fail")
                    }
                    else{  //未解任務
                        urlReport = "\(Config.HOST):\(Config.PORT)/\(Config.API_PATH)/report/create"
                        methodReport = Alamofire.HTTPMethod.post
                    }
                    

                    let reportImagePara : [String:Any] = ["operator_uid":self!.userID,"token":self!.token,"mid" : mid, "image":imageBase64!]

                    Alamofire.request(urlReport,method: methodReport, parameters:reportImagePara).validate().responseJSON{ response in
                        
                        switch response.result{
                        
                        case .success(let value):
                            self?.mission?.check = 1 //審核中
                            self?.showImage.image = image!
                            //let photoUpdateInfo = JSON(value)
                            //print(photoUpdateInfo.description)
                        case .failure(let error):
                            print(error)
                        }
                    }
                }else{
                    print("error happened")
                }
                self?.dismiss(animated: true, completion: nil)
            }
            self.present(cameraViewController, animated: true, completion: nil)
        }else if (mission?.check != 2) {
            let checkingAlert = UIAlertController(title: "Please wait", message:"Backend is still checking your photo, be patient.",preferredStyle: .alert)
            checkingAlert.addAction(UIAlertAction(title: "OK", style: .default))
            present(checkingAlert,animated: true)
        }else{
            let checkingAlert = UIAlertController(title: "What?", message:"Wanna be fail?",preferredStyle: .alert)
            checkingAlert.addAction(UIAlertAction(title: "OK", style: .default))
            present(checkingAlert,animated: true)
        }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage

        UIImageWriteToSavedPhotosAlbum(chosenImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        
        showImage.image = chosenImage
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
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





