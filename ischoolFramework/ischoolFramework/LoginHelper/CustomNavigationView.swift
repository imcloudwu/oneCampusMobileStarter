//
//  CustomNavigationView.swift
//  LoginHelper
//
//  Created by Cloud on 2016/3/2.
//  Copyright © 2016年 ischool. All rights reserved.
//

import UIKit

class CustomNavigationView : UINavigationController{
    
    var url : String!
    
    var loginHelper : LoginHelper?
    
    var after: (() -> Void)?
}
