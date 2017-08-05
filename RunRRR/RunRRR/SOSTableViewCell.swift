//
//  SOSTableViewCell.swift
//  RunRRR
//
//  Created by Yi-Chun on 2017/8/4.
//  Copyright © 2017年 EEECamp. All rights reserved.
//

import UIKit
import Alamofire
import CoreLocation
import SwiftyJSON

class SOSTableViewCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    let userID = UserDefaults.standard.integer(forKey: "RunRRR_UID")
    let token = UserDefaults.standard.string(forKey: "RunRRR_Token")!
    let smallCircle = UIImageView()
    let titleBarView = UIView()
    let titleLabel = UILabel()

  //  let emergencyInfoTextView = UITextView()
    
    let manager = CLLocationManager()
    var currentLocatoin : CLLocation!
    var vc: UIViewController?
    var teams : [String] = []
    var nicknames : [String] = []
    var names : [String] = []
    var phoneNumbers : [String] = []
    
    lazy var emergencyInfoCollectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
       // cv.backgroundColor = UIColor(red: 230/255, green: 230/255, blue:230/255, alpha: 1)
        cv.delegate = self
        cv.dataSource = self
        return cv
    }()
    
    
    let emergencyButton : UIButton = {
        let bt = UIButton(type: UIButtonType.system)
        bt.setTitle("SOS", for: .normal)
        bt.setTitleColor(UIColor(red: 27/255, green: 109/255, blue: 144/255, alpha: 1), for: .normal)
        bt.isEnabled = true
        bt.layer.borderWidth = 5
        bt.layer.cornerRadius = 5
        bt.layer.borderColor = UIColor(red: 27/255, green: 109/255, blue: 144/255, alpha: 1).cgColor
        return bt
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        emergencyInfoCollectionView.register(emergencyInfoCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        setupTitleBarView()
        setupView()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.teams.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 30)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as!emergencyInfoCollectionViewCell
            cell.squadNumberLabel.text = "\(teams[indexPath.item])小"
            cell.nameLabel.text = names[indexPath.item]
            cell.nicknameLabel.text = nicknames[indexPath.item]
            cell.phoneLabel.text = phoneNumbers[indexPath.item]
            cell.phoneLabel.dataDetectorTypes = UIDataDetectorTypes.phoneNumber
        
        return cell
    }
    
    func getHelp(_ sender: UIButton) {
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
    
    func getEmergencyInfo(){
        let emergencyInfoParameter : Parameters = ["operator_uid":self.userID,"token":self.token]
        Alamofire.request("\(API_URL)/utility/squadnumber", method: .get, parameters: emergencyInfoParameter).responseJSON{ response in
            
            switch(response.result){
            case .success(let value):
                let emergencyInfoArray = JSON(value)["object"].arrayValue
                print(emergencyInfoArray)
                for i in 0..<emergencyInfoArray.count{
                    self.teams.append(emergencyInfoArray[i]["team"].description)
                    self.nicknames.append(emergencyInfoArray[i]["nickname"].description)
                    self.names.append(emergencyInfoArray[i]["name"].description)
                    self.phoneNumbers.append(emergencyInfoArray[i]["phone"].description)
                }
                
            case .failure(let error):
                print(error)
            
            }
            self.emergencyInfoCollectionView.reloadData()
        }
    }
    func sosAlert(titleText : String, messageText: String){
        let alert = UIAlertController(title: titleText, message: messageText, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {(action) in
            alert.dismiss(animated: true, completion: nil)}))
        vc?.present(alert, animated: true, completion: nil)
    }

    func setupView(){
        contentView.addSubview(titleBarView)
       // contentView.addSubview(emergencyInfoTextView)
        contentView.addSubview(emergencyButton)
        contentView.addSubview(emergencyInfoCollectionView)
       
        
        contentView.addConstraintWithFormat(format: "H:|[v0]|", views: titleBarView)
        contentView.addConstraintWithFormat(format: "V:|[v0(50)]", views: titleBarView)
       // contentView.addConstraintWithFormat(format: "H:|-20-[v0]-20-|", views: emergencyInfoTextView)
        contentView.addConstraintWithFormat(format: "V:[v0]-10-[v1(40)]-10-[v2]-10-|", views: titleBarView,emergencyButton,emergencyInfoCollectionView)
        contentView.addConstraintWithFormat(format: "H:|-20-[v0]-20-|", views: emergencyInfoCollectionView)
        contentView.addConstraintWithFormat(format: "H:[v0(100)]", views: emergencyButton)
        addConstraint(NSLayoutConstraint(item: emergencyButton, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
    
        getEmergencyInfo()
        self.emergencyButton.addTarget(self, action: #selector(getHelp(_:)), for: .touchUpInside)
    }
    
    func setupTitleBarView(){
        titleBarView.backgroundColor = UIColor(red: 27/255, green: 109/255, blue: 144/255, alpha: 1)
        emergencyInfoCollectionView.backgroundColor = .white
        titleBarView.addSubview(smallCircle)
        titleBarView.addSubview(titleLabel)
        titleLabel.text = "SOS"
        titleLabel.textColor = .white
        
      
        
        smallCircle.image = UIImage(named: "bar_circle_icon")
        smallCircle.contentMode = .scaleAspectFill
        let smallCircleSize = titleBarView.frame.height - 4
        titleBarView.addConstraintWithFormat(format: "H:|-10-[v0(\(smallCircleSize))]-10-[v1]-5-|", views: smallCircle, titleLabel)
        titleBarView.addConstraintWithFormat(format: "V:|-2-[v0(\(smallCircleSize))]-2-|", views: smallCircle)
        titleBarView.addConstraintWithFormat(format: "V:|-2-[v0(\(smallCircleSize))]-2-|", views: titleLabel)
    }
    func hideContent(_ isHidden:Bool){
        self.emergencyButton.isHidden = isHidden
    }

}

class emergencyInfoCollectionViewCell : UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCellView()
    }
    
    let squadNumberLabel : UILabel = {
        let label = UILabel()
            label.text = "1小"
            label.textColor = UIColor(red: 27/255, green: 109/255, blue: 144/255, alpha: 1)
        return label
    }()
    
    let nameLabel : UILabel = {
        let label = UILabel()
            label.text = "黃宣傑"
            label.textColor = UIColor(red: 27/255, green: 109/255, blue: 144/255, alpha: 1)
//            label.backgroundColor = .black
        return label
    }()
    let nicknameLabel : UILabel = {
        let label = UILabel()
            label.text = "圖歐"
            label.textColor = UIColor(red: 27/255, green: 109/255, blue: 144/255, alpha: 1)
//        label.backgroundColor = .black
        return label
    }()
    let phoneLabel : UITextView = {
        let label = UITextView()
            label.text = "09-1234-5678"
            label.font = UIFont(name: "Courier", size: 16)
        
            label.dataDetectorTypes = UIDataDetectorTypes.phoneNumber
            //label.isUserInteractionEnabled = false
            label.isEditable = false
        return label
    }()
    
    
    func setupCellView(){
        addSubview(squadNumberLabel)
        addSubview(nameLabel)
        addSubview(nicknameLabel)
        addSubview(phoneLabel)
        
        //Vertical
        addConstraintWithFormat(format: "V:[v0(30)]", views: squadNumberLabel)
        addConstraint(NSLayoutConstraint(item: squadNumberLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        addConstraintWithFormat(format: "V:[v0(30)]", views: nameLabel)
        addConstraint(NSLayoutConstraint(item: nameLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        addConstraintWithFormat(format: "V:[v0(30)]", views: nicknameLabel)
        addConstraint(NSLayoutConstraint(item: nicknameLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        addConstraintWithFormat(format: "V:[v0(30)]", views: phoneLabel)
        addConstraint(NSLayoutConstraint(item: phoneLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
        
        //Horizonal
        addConstraintWithFormat(format: "H:|-5-[v0(30)]-5-[v1(60)]-5-[v2]-5-[v3(120)]|", views: squadNumberLabel, nameLabel, nicknameLabel, phoneLabel)
        
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
