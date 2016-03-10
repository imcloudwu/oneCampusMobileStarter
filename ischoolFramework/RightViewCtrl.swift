//
//  RightViewCtrl.swift
//  ischoolFramework
//
//  Created by Cloud on 2016/3/9.
//  Copyright © 2016年 ischool. All rights reserved.
//

import UIKit

class RightViewCtrl : ischoolViewCtrl{
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        self.navigationItem.title = "歡迎使用"
//    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationItem.title = "歡迎使用"
    }
}
