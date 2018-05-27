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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = frame
        self.worker = MapWorker()
        self.backgroundColor = UIColor.white
        
        self.addSubview(map)
        map.snp.makeConstraints{(make) in
            make.center.equalTo(self.snp.center)
            make.width.equalTo(self.snp.width).multipliedBy(0.8)
            make.height.equalTo(self.snp.height).multipliedBy(0.6)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
