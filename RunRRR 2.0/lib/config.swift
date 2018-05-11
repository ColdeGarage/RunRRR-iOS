//
//  config.swift
//  RunRRR 2.0
//
//  Created by Jacky Huang on 2018/5/11.
//  Copyright © 2018年 ColdeGarage. All rights reserved.
//

import Foundation

struct CONFIG{
    static let HOSTNAME = "nthuee.org"
    static let PORT = 8081
    static let VERSION = "api/v1.1"
    struct API_PREFIX {
        static let ROOT = "http://\(HOSTNAME):\(PORT)/\(VERSION)/"
    }
}
