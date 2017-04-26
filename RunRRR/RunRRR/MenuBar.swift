//
//  MenuBar.swift
//  RunRRR
//
//  Created by Jacky Huang on 2017/4/26.
//  Copyright © 2017年 EEECamp. All rights reserved.
//

import UIKit

class MenuBar: UIStackView {
    private var menuBarPages = [UIButton]()
    var pageInMenu : [String] = ["Map", "Mission", "Bag", "More"]
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtons()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupButtons(){
        for page in 0..<4 {
            let button = UIButton()
            button.backgroundColor = UIColor.white
            
            //add constraint
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: 58).isActive = true
            button.widthAnchor.constraint(equalToConstant: frame.width/4).isActive = true
            
            //setup the button action
            button.addTarget(self, action: #selector(MenuBar.segueToAnotherPage(button:)), for: .touchUpInside)
            
            button.setTitle(pageInMenu[page], for: .normal)
            button.setTitleColor(UIColor.blue, for: .normal)
            self.addArrangedSubview(button)
            menuBarPages.append(button)
        }
        
    }
    func segueToAnotherPage(button: UIButton){
        
    }
}
