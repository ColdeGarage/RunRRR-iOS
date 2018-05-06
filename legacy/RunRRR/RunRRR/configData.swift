//
//  configData.swift
//  RunRRR
//
//  Created by Jacky Huang on 2017/5/2.
//  Copyright © 2017年 EEECamp. All rights reserved.
//

import UIKit

struct Config{
    static let HOST = "http://coldegarage.tech"
    static let PORT = "8081"
    static let API_PATH = "api/v1.1"
}

let API_URL = "\(Config.HOST):\(Config.PORT)/\(Config.API_PATH)"
