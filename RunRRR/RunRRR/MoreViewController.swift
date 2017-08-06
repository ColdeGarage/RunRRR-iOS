//
//  MoreViewController.swift
//  RunRRR
//
//  Created by Starla on 2017/3/31.
//  Copyright © 2017年 EEECamp. All rights reserved.
//

import UIKit

class MoreViewController: UIViewController , UITableViewDelegate, UITableViewDataSource, segueViewController {
    @IBOutlet weak var moreTableView: UITableView!
    var prevVC : UIViewController?
    let expenedHeight : CGFloat = 300
    let defaultHeight : CGFloat = 50
    let menuBar : MenuBarBelow = {
        let menubar = MenuBarBelow()
        menubar.currentPage = "More"
        return menubar
    }()
    var preSelectedIndexPath:IndexPath?
    var selectedIndexPath:IndexPath?
    var istoggle:Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        prevVC?.dismiss(animated: false, completion: nil)
        menuBar.delegate = self
        menuBar.dataSource = self
        self.view.backgroundColor = UIColor(red: 230/255, green: 230/255, blue:230/255, alpha: 1)
        self.view.addSubview(menuBar)
        self.view.addConstraintWithFormat(format: "H:|[v0]|", views: menuBar)
        self.view.addConstraintWithFormat(format: "V:[v0(\(self.view.frame.height/6))]-0-|", views: menuBar)
        moreTableView.backgroundColor = UIColor(red: 230/255, green: 230/255, blue:230/255, alpha: 1)
        // Do any additional setup after loading the view.
        moreTableView.register(BarcodeTableViewCell.self, forCellReuseIdentifier: "BarcodeCell")
        moreTableView.register(AboutUsTableViewCell.self, forCellReuseIdentifier: "AboutUsCell")
        moreTableView.register(DieTableViewCell.self, forCellReuseIdentifier: "DieCell")
        moreTableView.register(SOSTableViewCell.self, forCellReuseIdentifier: "SOSCell")
        moreTableView.register(LogoutTableViewCell.self, forCellReuseIdentifier: "LogoutCell")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    private func tableViewSetup(cell:UITableViewCell){
        cell.layer.cornerRadius = 10
        cell.layer.borderWidth = 0
        cell.layer.masksToBounds = true
    }
    @available(iOS 2.0, *)
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 5
    }
    
    @available(iOS 2.0, *)
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
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
            moreCell.vc = self
            return moreCell
        case 3:
            let morecell = tableView.dequeueReusableCell(withIdentifier: "SOSCell", for: indexPath) as! SOSTableViewCell
            morecell.vc = self
            morecell.hideContent(!(selectedIndexPath==indexPath))
            tableViewSetup(cell: morecell)
            return morecell
        default:
            let moreCell = tableView.dequeueReusableCell(withIdentifier: "LogoutCell", for: indexPath) as! LogoutTableViewCell
            moreCell.hideContent(!(selectedIndexPath==indexPath))
            moreCell.vc = self
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
    
    func segueToMissions() {
        let vc = UIStoryboard(name: "Missions", bundle: nil).instantiateViewController(withIdentifier: "MissionsViewController") as! MissionsViewController
        //print(vc.description)
        vc.prevVC = self
        self.present(vc, animated: false, completion: nil)
    }
    
    func segueToMore() {}
    
    func segueToBags() {
        let vc = UIStoryboard(name: "Bag", bundle: nil).instantiateViewController(withIdentifier: "BagCollectionViewController") as! BagCollectionViewController
        //print(vc.description)
        vc.prevVC = self
        self.present(vc, animated: false, completion: nil)
    }
    
    func segueToMaps() {
        dismiss(animated: false, completion: nil)
    }

}
