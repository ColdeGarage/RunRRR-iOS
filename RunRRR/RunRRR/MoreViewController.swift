//
//  MoreViewController.swift
//  RunRRR
//
//  Created by Starla on 2017/3/31.
//  Copyright © 2017年 EEECamp. All rights reserved.
//

import UIKit

class MoreViewController: UIViewController , UITableViewDelegate, UITableViewDataSource {
    
    @IBAction func Back(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    let list = ["Barcode","Die","About","SOS","Logout"]
    let identities = ["Barcode","Die","About","SOS","Logout"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @available(iOS 2.0, *)
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return(list.count)
    }
    
    @available(iOS 2.0, *)
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let MoreCell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "MoreCell")
        MoreCell.textLabel?.text = list[indexPath.row]
        return(MoreCell)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let vcName = identities[indexPath.row]
        let viewController = storyboard?.instantiateViewController(withIdentifier: vcName)
        self.navigationController?.pushViewController(viewController!, animated: true)
    }
    
    
    



}
