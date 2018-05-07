//
//  ViewController.swift
//  RunRRR 2.0
//
//  Created by Jacky Huang on 2018/4/22.
//  Copyright © 2018年 ColdeGarage. All rights reserved.
//

import UIKit
import SnapKit

class MainViewController: UIViewController, LoginButtonDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.backgroundColor = UIColor.blue
        viewInit()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewInit() {
        let loginUIView = LoginUIView()
        loginUIView.loginButtonDelegate = self
        
        let tap: UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.hideKeyboard))
        
        tap.cancelsTouchesInView = false
        loginUIView.addGestureRecognizer(tap)
        view.addSubview(loginUIView)
        
        
        
        loginUIView.snp.makeConstraints{ (make) in
            make.bottom.equalTo(view)
            make.left.equalTo(view)
            make.right.equalTo(view)
            
            if #available(iOS 11, *) {
                make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin)
            }
            else {
                make.top.equalTo(view.snp.topMargin)
            }
        }
    }
    internal func buttonOnTouch() {
        print("Login Button Tapped")
        // present(<#T##viewControllerToPresent: UIViewController##UIViewController#>, animated: <#T##Bool#>, completion: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>)
    }
}

protocol LoginButtonDelegate {
    func buttonOnTouch()
}
