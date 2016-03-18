//
//  AddChildMainViewCtrl.swift
//  ischoolFramework
//
//  Created by Cloud on 2016/3/16.
//  Copyright © 2016年 ischool. All rights reserved.
//

import UIKit

class AddChildMainViewCtrl : ischoolViewCtrl{
    
    var Resource : Resources!
    
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var view3: UIView!
    
    override func viewWillAppear(animated: Bool) {
        
        self.navigationItem.title = "加 入 小 孩"
        
        let tap1 = UITapGestureRecognizer(target: self, action: "GotoScanCodeViewCtrl")
        view1.addGestureRecognizer(tap1)
        
        let tap2 = UITapGestureRecognizer(target: self, action: "GotoKeyinByCodeViewCtrl")
        view2.addGestureRecognizer(tap2)
        
        let tap3 = UITapGestureRecognizer(target: self, action: "GotoKeyinByBasicViewCtrl")
        view3.addGestureRecognizer(tap3)
        
        SetShadow(view1)
        
        SetShadow(view2)
        
        SetShadow(view3)
    }
    func SetShadow(view:UIView){
        
        view.layer.shadowColor = UIColor.blackColor().CGColor
        view.layer.shadowOffset = CGSizeMake(3.0, 3.0) // [水平偏移, 垂直偏移]
        view.layer.shadowOpacity = 0.5 // 0.0 ~ 1.0 的值
        view.layer.shadowRadius = 5.0 // 陰影發散的程度
        
    }
    
    func GotoScanCodeViewCtrl(){
        
        let view = frameworkStoryboard.instantiateViewControllerWithIdentifier("ScanCodeViewCtrl") as! ScanCodeViewCtrl
        
        view.Resource = self.Resource
        
        self.navigationController?.pushViewController(view, animated: true)
    }
    
    func GotoKeyinByCodeViewCtrl(){
        
        let view = frameworkStoryboard.instantiateViewControllerWithIdentifier("KeyinByCodeViewCtrl") as! KeyinByCodeViewCtrl
        
        view.Resource = self.Resource
        
        self.navigationController?.pushViewController(view, animated: true)
    }
    
    func GotoKeyinByBasicViewCtrl(){
        
        let view = frameworkStoryboard.instantiateViewControllerWithIdentifier("KeyinByBasicViewCtrl") as! KeyinByBasicViewCtrl
        
        view.Resource = self.Resource
        
        self.navigationController?.pushViewController(view, animated: true)
    }
}
