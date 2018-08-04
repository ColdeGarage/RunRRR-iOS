//
//  MoreWorker.swift
//  RunRRR 2.0
//
//  Created by Jacky Huang on 2018/5/27.
//  Copyright © 2018年 ColdeGarage. All rights reserved.
//

import UIKit

class MoreWorker: NSObject, Worker, UITableViewDataSource, UITableViewDelegate {
    var moreTableView: UITableView?
    init(moreTableView: UITableView) {
        self.moreTableView = moreTableView
    }
    let expenedHeight : CGFloat = 300
    let defaultHeight : CGFloat = 50
    var preSelectedIndexPath:IndexPath?
    var selectedIndexPath:IndexPath?
    var istoggle:Bool = false
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    private func tableViewSetup(cell: UITableViewCell){
        cell.layer.cornerRadius = 10
        cell.layer.borderWidth = 0
        cell.layer.masksToBounds = true
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.item {
        case 0:
            let moreCell = tableView.dequeueReusableCell(withIdentifier: "BarcodeCell", for: indexPath) as! BarcodeTableViewCell
            moreCell.hideContent(!(selectedIndexPath==indexPath))
            tableViewSetup(cell: moreCell)
            return moreCell
        case 1:
            let moreCell = tableView.dequeueReusableCell(withIdentifier: "AboutUsCell", for: indexPath) as! AboutUsTableViewCell
            moreCell.hideContent(!(selectedIndexPath==indexPath))
            tableViewSetup(cell: moreCell)
            return moreCell
        case 2:
            let moreCell = tableView.dequeueReusableCell(withIdentifier: "DieCell", for: indexPath) as! DieTableViewCell
            moreCell.hideContent(!(selectedIndexPath==indexPath))
            tableViewSetup(cell: moreCell)
            return moreCell
        case 3:
            let morecell = tableView.dequeueReusableCell(withIdentifier: "SOSCell", for: indexPath) as! SOSTableViewCell
            morecell.hideContent(!(selectedIndexPath==indexPath))
            tableViewSetup(cell: morecell)
            return morecell
        default:
            let moreCell = tableView.dequeueReusableCell(withIdentifier: "LogoutCell", for: indexPath) as! LogoutTableViewCell
            moreCell.hideContent(!(selectedIndexPath==indexPath))
            tableViewSetup(cell: moreCell)
            return moreCell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if selectedIndexPath == indexPath{
            return expenedHeight
        }
        return defaultHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        print(indexPath.description)
        tableView.reloadData()
    }
    
}
