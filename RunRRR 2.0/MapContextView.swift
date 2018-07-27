//
//  MapContextView.swift
//  RunRRR 2.0
//
//  Created by Jacky Huang on 2018/5/27.
//  Copyright © 2018年 ColdeGarage. All rights reserved.
//

import UIKit
import GoogleMaps

class MapContextView: ContextView {
    let map: GMSMapView = {
        let gmap = GMSMapView()
        gmap.camera = GMSCameraPosition.camera(withLatitude: 24.794589, longitude: 120.993393, zoom: 15.0)
        gmap.isMyLocationEnabled = true
        gmap.settings.myLocationButton = true
        gmap.settings.zoomGestures = true
        gmap.layer.cornerRadius = 10
        gmap.layer.masksToBounds = true
        return gmap
    }()
    
    let pointSquare : UILabel = {
        let label = UILabel()
        label.text = "0"
        label.textAlignment = .left
        label.layer.borderWidth = 0
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 48)
        return label
    }()
    
    let pointLabel : UILabel = {
        let label = UILabel()
        label.text = "POINT"
        label.textColor = UIColor.gray
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.worker = MapWorker(map: map, point: pointSquare, target: self) as MapWorker
        self.backgroundColor = UIColor(hexString: "#FAFBFC")
        
        self.addSubview(pointSquare)
        self.addSubview(pointLabel)
        self.addSubview(map)
        map.snp.makeConstraints {(make) in
            make.center.equalTo(self.snp.center)
            make.width.equalTo(self.snp.width).multipliedBy(0.8)
            make.height.equalTo(self.snp.height).multipliedBy(0.6)
        }
        pointLabel.snp.makeConstraints{ (make) in
            make.left.equalTo(map).offset(30)
            make.width.equalTo(60)
            make.top.equalTo(self.snp.top).offset(40)
            make.height.equalTo(30)
        }
        pointSquare.snp.makeConstraints{ (make) in
            make.left.equalTo(pointLabel.snp.right).offset(30)
            make.right.equalTo(map).offset(-20)
            make.top.equalTo(self.snp.top).offset(40)
            make.height.equalTo(50)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillBeDisplayed() {
        let mapWorker = self.worker as! MapWorker
        mapWorker.loadMapData()
        mapWorker.loadLocationData()
        mapWorker.loadPointData()
    }

}
