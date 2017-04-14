//
//  missionsData.swift
//  RunRRR
//
//  Created by Yi-Chun on 2017/4/6.
//  Copyright © 2017年 EEECamp. All rights reserved.
//

import Foundation

class MissionsData{
    
    var mid:Int
    var title:String
    var content:String
    var timeStart:String
    var timeEnd:String
    var price:Int
    var clue:Int
    var type:String            //主，支，緊急
    var score:Int
    var locationE:Double
    var locationN:Double
    var check:String           //Mission status check
                            //0:not sloved, 1:checking 2:complete
    
    
    enum checkType:String{
        case unsloved, review, complete
    }
    
    struct PropertyKey {
        static let mid = "mid"
        static let title = "title"
        static let content = "content"
        static let timeStart = "timeStart"
        static let timeEnd = "timeEnd"
        static let price = "price"
        static let clue = "clue"
        static let type = "type"
        static let score = "score"
        static let locationE = "locationE"
        static let locationN = "locationN"
        
    }
    
    init?(mid:Int,title:String,content:String,timeStart:String,timeEnd:String,price:Int,
          clue:Int,type:String,score:Int,locationE:Double,locationN:Double){
    
        guard !title.isEmpty else{
            return nil
        }

        guard !content.isEmpty else{
            return nil
        }
        
        guard !timeStart.isEmpty else{
            return nil
        }
        
        guard !timeEnd.isEmpty else{
            return nil
        }
        
        self.mid = mid
        self.title = title
        self.content = content
        self.timeStart = timeStart
        
        let timeEnd = timeEnd.components(separatedBy: "T")[1]
        let timeHour = timeEnd.components(separatedBy: ":")[0]
        let timeMin = timeEnd.components(separatedBy: ":")[1]
        self.timeEnd = timeHour + ":" + timeMin
        
        self.price = price
        self.clue = clue
        switch type{
        case "URG":
            self.type = "1"
        case "MAIN":
            self.type = "2"
        case "SUB":
            self.type = "3"
        default:
            self.type = "?"
        }
        
        //self.type = type
        self.score = score
        self.locationE = locationE
        self.locationN = locationN
        self.check = "unsolved"
        
    }
    
    
    
    
    
    

}