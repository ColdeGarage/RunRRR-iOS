//
//  Items_Clues.swift
//  RunRRR
//
//  Created by Jacky Huang on 2017/4/8.
//  Copyright © 2017年 EEECamp. All rights reserved.
//

import UIKit
class Pack: NSObject{
    var pid: Int?
    var itemClass: itemClasses?
    enum itemClasses{
        case tool
        case clue
    }
    var id: Int?
}
class Clue: NSObject{
    var cid: Int?
    var content: String?
    init?(cid: Int, content: String){
        self.cid = cid
        self.content = content
    }
}
class Tool: NSObject{
    var tid: Int?
    var name: String?
    var content: String?
    var imageURL: String?
    var expireSec: Int?
    var price: Int?
}
