//
//  FunctionShell.swift
//  ischoolFramework
//
//  Created by Cloud on 2016/3/7.
//  Copyright © 2016年 ischool. All rights reserved.
//

import Foundation

public protocol ischoolProtocol{
    
    static var Instance : ischoolProtocol { get }
    
    var Name : String { get }
    
    var Scope : String { get }
    
    var Icon : UIImage? { get }
    
    var BundleId : NSBundle? { get }
    
    var Storyboard : UIStoryboard? { get }
    
    func GetViewController() -> ischoolViewCtrl
    
}