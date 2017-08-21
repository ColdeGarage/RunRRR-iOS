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
    
    //var imagePicker: UIImagePickerController!
    let userID = UserDefaults.standard.integer(forKey: "RunRRR_UID")
    let token = UserDefaults.standard.string(forKey: "RunRRR_Token")!
    var mission : MissionsData?
    var missionReportImage2Show : UIImage?
    //var missionReportImage: UIImageView?
    //var missionImage: UIImageView?

    
    let cameraButton : UIButton = {
        let button = UIButton()
        button.isEnabled = true
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.setTitleColor(UIColor.red, for: .normal)
        button.setTitle("UPLOAD", for: .normal)
        button.titleLabel?.textAlignment = NSTextAlignment.center
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMissionDetail()
        isCameraButton()
        cameraButton.addTarget(self, action: #selector(choosePhoto), for: .touchUpInside)
     //   self.missionImage?.contentMode = .scaleAspectFit
       // self.missionReportImage?.contentMode = .scaleAspectFit
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    func isCameraButton(){
        
        let parameterSent : Parameters = ["operator_uid":self.userID, "token":self.token, "uid":self.userID]
        Alamofire.request("\(Config.HOST):\(Config.PORT)/\(Config.API_PATH)/member/read",method: .get, parameters: parameterSent).validate().responseJSON{ response in
                if response.result.isSuccess {
                    let statusJson = JSON(response.result.value!)
                    let statusArray = statusJson["payload"]["objects"].arrayValue
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
    
    
    func choosePhoto() {
        if (mission?.check != 1) && (mission?.check != 3){
            let croppingEnabled = false
            let cameraViewController = ALCameraViewController.CameraViewController(croppingEnabled: croppingEnabled) { [weak self] image, asset in
                // Do something with your image here.
                // If cropping is enabled this image will be the cropped version
                let jpegCompressionQuality: CGFloat = 0.1
                let imageBase64 = UIImageJPEGRepresentation(image!, jpegCompressionQuality)?.base64EncodedString()
                if let mid = self?.mission?.mid{
                    var urlReport:URLConvertible
                    var methodReport:HTTPMethod
                    var reportImagePara : Parameters
                    if self?.mission?.check == 0 {  //失敗任務
                        urlReport = "\(Config.HOST):\(Config.PORT)/\(Config.API_PATH)/report/edit"
                        methodReport = Alamofire.HTTPMethod.put
                        reportImagePara = ["operator_uid":self!.userID,"token":self!.token,"rid" : self!.mission!.rid!, "image":imageBase64!]
                        
                        //print("fail")
                    }
                    else{  //未解任務
                        urlReport = "\(Config.HOST):\(Config.PORT)/\(Config.API_PATH)/report/create"
                        methodReport = Alamofire.HTTPMethod.post
                        reportImagePara = ["operator_uid":self!.userID,"token":self!.token,"mid" : mid, "image":imageBase64!]
                    }
                    
                    
//                    let reportImagePara : [String:Any] = ["operator_uid":self!.userID,"token":self!.token,"mid" : mid, "image":imageBase64!]
                    
                    Alamofire.request(urlReport,method: methodReport, parameters:reportImagePara).validate().responseData{ response in
                        //print("watch here")
                        //print(response)
                        switch response.result{
                            
                        case .success( _):
                            
                            self?.missionReportImage2Show = image
                            self?.mission?.check = 1 //審核中
                            self?.setupMissionDetail()
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
        }else if (mission?.check == 1) {
            let checkingAlert = UIAlertController(title: "Please wait", message:"Backend is still checking your photo, be patient.",preferredStyle: .alert)
            checkingAlert.addAction(UIAlertAction(title: "OK", style: .default))
            present(checkingAlert,animated: true)
        }else{
            let checkingAlert = UIAlertController(title: "What?", message:"Wanna be fail?",preferredStyle: .alert)
            checkingAlert.addAction(UIAlertAction(title: "OK", style: .default))
            present(checkingAlert,animated: true)
        }
    }
    
    /*func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        UIImageWriteToSavedPhotosAlbum(chosenImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        
        missionReportImage?.image = chosenImage
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
    */
    
    func dismissDetail(){
        self.dismiss(animated: false, completion: nil)
    }
    
 
    
    
    
    
    
    
    func setupMissionDetail(){
        view.backgroundColor = UIColor(red: 230/255, green: 230/255, blue:230/255, alpha: 1)
        
        
        
        let missionPriorityLabel : UILabel = {
            let label = UILabel()
            if let missionPriority = mission?.type{
                switch(missionPriority){
                case "1":
                    label.text = "限"
                    label.textColor = UIColor(red: 255/255, green: 41/255, blue:41/255, alpha: 1)
                    
                case "2":
                    label.text = "主"
                    label.textColor = UIColor(red: 75/255, green: 220/255, blue:191/255, alpha: 1)
                    
                case "3":
                    label.text = "支"
                    label.textColor = UIColor(red: 245/255, green: 157/255, blue:52/255, alpha: 1)
                default:
                    label.text = "?"
                }
            }
            label.layer.cornerRadius = 35
            label.font = UIFont.systemFont(ofSize: 36)
            label.clipsToBounds = true
            label.backgroundColor = UIColor.white
            label.textAlignment = .center
            return label
        }()
        
        
        
        
        
        let cancelButton : UIButton = {
            let button = UIButton()
            button.isEnabled = true
            button.addTarget(self, action: #selector(dismissDetail), for: .touchUpInside)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
            button.setTitleColor(UIColor.black, for: .normal)
            button.setTitle("CANCEL", for: .normal)
            button.titleLabel?.textAlignment = NSTextAlignment.center
            button.layer.borderWidth = 0
            return button
        }()
        
        
        
        
        
        
        
        
        
        
        
        let missionTimingLabel : UILabel = {
            let label = UILabel()
            label.text = mission?.timeEnd
            label.textColor = UIColor.darkGray
            
            return label
        }()
        
        
        
        
        
        
        
        let missionStatusImage: UIImageView = {
            let status = UIImageView()
            status.layer.borderWidth = CGFloat(0)
            status.layer.borderColor = UIColor.white.cgColor
            status.layer.cornerRadius = 15
            status.layer.masksToBounds = true
            status.layer.backgroundColor = UIColor(red: 230/255, green: 230/255, blue:230/255, alpha: 0).cgColor
            if let missionStatus = mission?.check{
                
                switch (missionStatus) {
                case 0:
                    status.image = UIImage(named: "state_failed")
                case 1: //審核中
                    status.image = UIImage(named: "state_waiting")
                case 3:
                    status.image = UIImage(named: "state_passed")
                default: //未解任務
                    status.backgroundColor = UIColor(red: 230/255, green: 230/255, blue:230/255, alpha: 0)
                }
            }
            return status
        }()
        
        
        
        let missionNameLabel : UILabel = {
            let label = UILabel()
            
            label.textColor = UIColor.white
            label.text = mission?.title
            label.textAlignment = .center
            return label
        }()
        
        let missionTopView : UIView = {
            let view = UIView()
            if let missionPriority = mission?.type{
                switch(missionPriority){
                case "1":
                    view.backgroundColor = UIColor(red: 255/255, green: 41/255, blue:41/255, alpha: 1)
                    
                case "2":
                    view.backgroundColor = UIColor(red: 75/255, green: 220/255, blue:191/255, alpha: 1)
                    
                case "3":
                    view.backgroundColor = UIColor(red: 245/255, green: 157/255, blue:52/255, alpha: 1)
                default:
                    view.backgroundColor = UIColor.white
                }
            }
            return view
        }()
        
        let missionContentTextView : UITextView = {
            let textView = UITextView()
            let price = mission?.prize.description
            let score = mission?.score.description
            textView.text = (mission?.content)! + "\n\n任務獎勵金錢 : " + price! + "\n任務獎勵分數 : " + score!
            textView.backgroundColor = UIColor(red: 230/255, green: 230/255, blue:230/255, alpha: 1)
            textView.isScrollEnabled = true
            textView.isEditable = false
            return textView
        }()
        
        
        
        
        let missionImage: UIImageView = {
            let image = UIImageView()
            if let remoteMissionImage = mission?.missionImageURL{
                let missionImageURL:URLConvertible = "\(Config.HOST):\(Config.PORT)/\(Config.API_PATH)/download/img/" + remoteMissionImage
                Alamofire.request(missionImageURL).validate().responseData{ response in
                    switch response.result{
                    case .success(let value):
                        let missionImage2Show = UIImage(data:value)!
                        image.image = missionImage2Show
                    case .failure(let error):
                        print(error)
                    }
                }
            }else{
                print("No photo mission")
            }
 
            
            image.contentMode = .scaleAspectFit
            image.layer.borderWidth = CGFloat(2)
            image.layer.borderColor = UIColor.white.cgColor
            image.layer.cornerRadius = 5
            image.layer.masksToBounds = true
            return image
        }()
        
        
        
        
        let missionReportImage: UIImageView = {
            let image = UIImageView()
            if self.missionReportImage2Show == nil{
                if let remoteImage = mission?.imageURL{
                    let imageURL:URLConvertible = "\(Config.HOST):\(Config.PORT)/\(Config.API_PATH)/download/img/" + remoteImage
                    Alamofire.request(imageURL).validate().responseData{ response in
                        switch response.result{
                        case .success(let value):
                            let image2Show = UIImage(data:value)!
                            
                            image.image = image2Show
                        case .failure(let error):
                            print(error)
                        }
                    }
                }else{
                    print("no photo")
                }
            }else{
                image.image = self.missionReportImage2Show
            
            }
            image.contentMode = .scaleAspectFit
            image.layer.borderWidth = CGFloat(2)
            image.layer.borderColor = UIColor.white.cgColor
            image.layer.cornerRadius = 5
            image.layer.masksToBounds = true
            return image
        }()
        
        
        
        
        view.subviews.forEach({$0.removeFromSuperview()})
        view.addSubview(missionTopView)
        view.addSubview(missionReportImage)
        view.addSubview(missionPriorityLabel)
        view.addSubview(cancelButton)
        view.addSubview(cameraButton)
        view.addSubview(missionTimingLabel)
        view.addSubview(missionStatusImage)
        view.addSubview(missionNameLabel)
        view.addSubview(missionContentTextView)
        view.addSubview(missionImage)
        
        view.addConstraintWithFormat(format: "V:|-20-[v0(80)]", views: missionTopView)
        view.addConstraintWithFormat(format: "V:|-25-[v0(70)]", views: missionPriorityLabel)
        view.addConstraintWithFormat(format: "V:|-65-[v0(30)]", views: missionTimingLabel)
        view.addConstraintWithFormat(format: "V:|-70-[v0(30)]", views: missionStatusImage)
        
        
        view.addConstraintWithFormat(format: "V:|-25-[v0(70)]-\(view.frame.height/25)-[v1]-\(view.frame.height/25)-[v2(\(view.frame.height/5))]-\(view.frame.height/25)-[v3(\(view.frame.height/5))]-\(view.frame.height/25)-[v4]",
            views: missionNameLabel,missionContentTextView, missionImage, missionReportImage, cameraButton)
        view.addConstraintWithFormat(format: "V:[v0(\(view.frame.height/15))]-\(view.frame.height/20)-|", views: cancelButton)
        view.addConstraintWithFormat(format: "V:[v0(\(view.frame.height/15))]-\(view.frame.height/20)-|", views: cameraButton)
        
        
        
        view.addConstraintWithFormat(format: "H:|-\(view.frame.width/8)-[v0]-\(view.frame.width/8)-|", views: missionContentTextView)
        view.addConstraintWithFormat(format: "H:|[v0(\(view.frame.width))]|", views: missionTopView)
        
        view.addConstraintWithFormat(format: "H:|-5-[v0(70)]-5-[v1]-5-[v2(50)]-5-|", views: missionPriorityLabel, missionNameLabel,missionTimingLabel)
        
        view.addConstraintWithFormat(format: "H:|-50-[v0(30)]", views: missionStatusImage)

        
        
        view.addConstraintWithFormat(format: "H:[v0(100)]-\(view.frame.width/10)-|", views: cameraButton)

        
        view.addConstraintWithFormat(format: "H:|-\(view.frame.width/10)-[v0(100)]", views: cancelButton)
        
        
        
        view.addConstraintWithFormat(format: "H:|-\(view.frame.width/8)-[v0]-\(view.frame.width/8)-|", views: missionImage)
        view.addConstraintWithFormat(format: "H:|-\(view.frame.width/8)-[v0]-\(view.frame.width/8)-|", views: missionReportImage)
        
   
    }
    
    
    

}









