//
//  MapWorker.swift
//  RunRRR 2.0
//
//  Created by Jacky Huang on 2018/5/27.
//  Copyright © 2018年 ColdeGarage. All rights reserved.
//

import UIKit
import GoogleMaps

class MapWorker: Worker {
    var map: GMSMapView
    var view: MapContextView

    init(map: GMSMapView, target: MapContextView) {
        self.map = map
        self.view = target
    }
    
    func loadMapData() {
        self.map.clear()
        self.getMapsBoundary()
        self.getMissionLocations()
    }
    
    private func getMapsBoundary() {
        
    }
    private func getMissionLocations() {
        
    }
}
