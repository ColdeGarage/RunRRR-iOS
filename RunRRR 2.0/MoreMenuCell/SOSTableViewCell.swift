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
import SnapKit

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
        bt.setTitleColor(UIColor(red: 250/255, green: 105/255, blue: 89/255, alpha: 1), for: .normal)
        bt.isEnabled = true
        bt.layer.borderWidth = 5
        bt.layer.cornerRadius = 5
        bt.layer.borderColor = UIColor(red: 250/255, green: 105/255, blue: 89/255, alpha: 1).cgColor
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
    
    @objc func getHelp(_ sender: UIButton) {
        let currentLocation = self.manager.location!
        let currentLocationLatitude = currentLocation.coordinate.latitude
        let currentLocationLongitude = currentLocation.coordinate.longitude
        
        let sosParameter : Parameters = ["operator_uid":self.userID,"token":self.token, "uid":self.userID, "position_e":currentLocationLongitude, "position_n":currentLocationLatitude, "help_status": 1 as Int]
        Alamofire.request("\(CONFIG.API_PREFIX.ROOT)/member/callhelp", method: .put, parameters: sosParameter).responseJSON{ response in
            switch(response.result){
            case .success( _):
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
        Alamofire.request("\(CONFIG.API_PREFIX.ROOT)/utility/squadnumber", method: .get, parameters: emergencyInfoParameter).responseJSON{ response in
            
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
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
    }

    func setupView(){
        contentView.snp.makeConstraints{(make) in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        contentView.addSubview(titleBarView)
        contentView.addSubview(emergencyButton)
        contentView.addSubview(emergencyInfoCollectionView)
       
        titleBarView.snp.makeConstraints{(make) in
            make.left.right.equalTo(contentView)
            make.top.equalTo(contentView)
            make.height.equalTo(50)
        }
        
        emergencyButton.snp.makeConstraints{(make) in
            make.width.equalTo(100)
            make.centerX.equalTo(contentView)
            make.top.equalTo(titleBarView.snp.bottom).offset(10)
            make.height.equalTo(40)
        }
        
        emergencyInfoCollectionView.snp.makeConstraints{(make) in
            make.left.equalTo(contentView).offset(20)
            make.right.equalTo(contentView).offset(-20)
            make.top.equalTo(emergencyButton.snp.bottom).offset(10)
            make.bottom.equalTo(contentView).offset(-10)
        }
        
        getEmergencyInfo()
        self.emergencyButton.addTarget(self, action: #selector(getHelp(_:)), for: .touchUpInside)
    }
    
    func setupTitleBarView(){
        titleBarView.backgroundColor = UIColor(red: 250/255, green: 105/255, blue: 89/255, alpha: 1)
        emergencyInfoCollectionView.backgroundColor = .clear
        titleBarView.addSubview(smallCircle)
        titleBarView.addSubview(titleLabel)
        titleLabel.text = "SOS"
        titleLabel.textColor = .white
        smallCircle.image = UIImage(named: "bar_circle_icon")
        smallCircle.contentMode = .scaleAspectFill
        
//        let smallCircleSize = titleBarView.frame.height - 4
        
        smallCircle.snp.makeConstraints{(make) in
            make.left.equalTo(titleBarView).offset(10)
            make.width.equalTo(titleBarView.snp.height).multipliedBy(0.8)
            make.top.equalTo(titleBarView).offset(2)
            make.height.equalTo(titleBarView.snp.height).multipliedBy(0.8)
        }
        
        titleLabel.snp.makeConstraints{(make) in
            make.left.equalTo(smallCircle.snp.right).offset(10)
            make.right.equalTo(titleBarView).offset(-5)
            make.top.equalTo(titleBarView).offset(2)
            make.bottom.equalTo(titleBarView).offset(-2)
        }
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
            label.textColor = UIColor(red: 250/255, green: 105/255, blue: 89/255, alpha: 1)
        return label
    }()
    
    let nameLabel : UILabel = {
        let label = UILabel()
            label.text = "黃宣傑"
            label.textColor = UIColor(red: 250/255, green: 105/255, blue: 89/255, alpha: 1)
//            label.backgroundColor = .black
        return label
    }()
    let nicknameLabel : UILabel = {
        let label = UILabel()
            label.text = "圖歐"
            label.textColor = UIColor(red: 250/255, green: 105/255, blue: 89/255, alpha: 1)
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
        squadNumberLabel.snp.makeConstraints{(make) in
            make.centerY.equalTo(self)
            make.height.equalTo(30)
            make.left.equalTo(self).offset(5)
            make.width.equalTo(30)
        }
        
        nameLabel.snp.makeConstraints{(make) in
            make.centerY.equalTo(self)
            make.height.equalTo(30)
            make.left.equalTo(squadNumberLabel.snp.right).offset(5)
            make.width.equalTo(60)
        }
        
        nicknameLabel.snp.makeConstraints{(make) in
            make.centerY.equalTo(self)
            make.height.equalTo(30)
            make.left.equalTo(nameLabel.snp.right).offset(5)
            make.right.equalTo(phoneLabel.snp.left).offset(-5)
        }
        
        phoneLabel.snp.makeConstraints{(make) in
            make.centerY.equalTo(self)
            make.height.equalTo(30)
            make.width.equalTo(120)
            make.right.equalTo(self)
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
