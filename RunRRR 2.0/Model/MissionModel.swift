//
//  MissionModel.swift
//  RunRRR 2.0
//
//  Created by Jacky Huang on 2018/7/2.
//  Copyright © 2018年 ColdeGarage. All rights reserved.
//

import Foundation
import UIKit

struct Mission {
//    init() {
//        
//    }
    var title: String
    var mid: Int
    var content: String
    var timeStart: Int
    var timeEnd: Int
    var price: Int
    var clueID: Int
    var type: MissionType
    var score: Int
    var url: String
    var locationE: Double
    var locationN: Double
    var timeCreate: Int
}

enum MissionType {
    case MAIN
    case SUB
    case URG
}
