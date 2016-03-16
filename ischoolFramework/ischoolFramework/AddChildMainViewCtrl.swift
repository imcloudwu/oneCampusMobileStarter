//
//  AddChildMainViewCtrl.swift
//  ischoolFramework
//
//  Created by Cloud on 2016/3/16.
//  Copyright © 2016年 ischool. All rights reserved.
//

import UIKit

class AddChildMainViewCtrl : ischoolViewCtrl{
    
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var view3: UIView!
    
    override func viewWillAppear(animated: Bool) {
        
        self.navigationItem.title = "加 入 小 孩"
        
        view1.layer.masksToBounds = true
        view1.layer.cornerRadius = 5
        
        view2.layer.masksToBounds = true
        view2.layer.cornerRadius = 5
        
        view3.layer.masksToBounds = true
        view3.layer.cornerRadius = 5
        
        let tap1 = UITapGestureRecognizer(target: self, action: "Action1")
        let tap2 = UITapGestureRecognizer(target: self, action: "Action1")
        let tap3 = UITapGestureRecognizer(target: self, action: "Action1")
        
        view1.addGestureRecognizer(tap1)
        
        view2.addGestureRecognizer(tap2)
        
        view3.addGestureRecognizer(tap3)
    }
    
    func Action1(){
        
        print("Action1")
        
        let view = frameworkStoryboard.instantiateViewControllerWithIdentifier("test")
        
        self.navigationController?.pushViewController(view, animated: true)
    }
}
