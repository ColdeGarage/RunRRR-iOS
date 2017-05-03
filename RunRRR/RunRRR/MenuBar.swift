//
//  MenuBar.swift
//  RunRRR
//
//  Created by Jacky Huang on 2017/4/26.
//  Copyright © 2017年 EEECamp. All rights reserved.
//

import UIKit

@IBDesignable class MenuBar: UIStackView {
    private var menuBarPages = [UIButton]()
    var pageInMenu : [String] = ["Map", "Mission", "Bag", "More"]
    init(_ pageFrom: String) {
        super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        setupStackView()
        setupButtons(pageFrom)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setupStackView(){
        axis = .horizontal
        alignment = .fill
        spacing = 0
        distribution = .fillEqually
    }
    private func setupButtons(_ pageFrom: String){
        for page in 0..<4 {
            let button = UIButton()
            button.backgroundColor = UIColor.white
            
            //add constraint
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: 58).isActive = true
            button.widthAnchor.constraint(equalToConstant: frame.width/4).isActive = true
            
            //setup the button action
            button.setTitle(pageInMenu[page], for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            button.isEnabled = true
            button.setTitleColor(UIColor.black, for: .normal)
            self.addArrangedSubview(button)
            menuBarPages.append(button)
        }
        
    }
}
