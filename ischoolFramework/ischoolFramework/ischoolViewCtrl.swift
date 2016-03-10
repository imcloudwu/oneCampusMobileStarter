//
//  ischoolViewCtrl.swift
//  ischoolFramework
//
//  Created by Cloud on 2016/3/7.
//  Copyright © 2016年 ischool. All rights reserved.
//

import UIKit

public class ischoolViewCtrl : UIViewController,InfoChangeDelegate{
    
    public var navtitle : String?
    
    public var passValue : PassValue?
    
    public final override func viewDidLoad() {
        
        let img = UIImage(named: "Menu-24.png", inBundle: frameworkBundle, compatibleWithTraitCollection: nil)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: img, style: UIBarButtonItemStyle.Plain, target: self, action: "ToggleSideMenu")
        
        self.navigationItem.title = navtitle
        
        self.passValue?.delegate = self
    }
    
    func ToggleSideMenu(){
        
        SlideView.ToggleSideMenu()
    }
    
    public func DsnsChanged(dsns:String){ }
    
    public func StudentIdChanged(studentId:String){ }
}
