//
//  DisciplineShell.swift
//  DisciplineModule
//
//  Created by Cloud on 2016/3/14.
//  Copyright © 2016年 ischool. All rights reserved.
//

import Foundation
import ischoolFramework

public class DisciplineShell : ischoolProtocol{
    
    public static var Instance : ischoolProtocol{
        
        get{
            return DisciplineShell()
        }
    }
    
    public var Name : String{
        
        get{
            return "獎 懲 查 詢"
        }
    }
    
    public var Scope : String{
        
        get{
            return "1campus.mobile.parent"
        }
    }
    
    public var Icon : UIImage?{
        
        get{
            return UIImage(named: "Attention Filled-50.png", inBundle: BundleId, compatibleWithTraitCollection: nil)
        }
    }
    
    public var BundleId : NSBundle?{
        
        get{
            return NSBundle(identifier: "tw.ischool.DisciplineModule")
        }
    }
    
    public var Storyboard : UIStoryboard?{
        
        get{
            return UIStoryboard(name: "Storyboard", bundle: BundleId)
        }
    }
    
    public func GetViewController() -> ischoolViewCtrl{
        
        let v = Storyboard?.instantiateViewControllerWithIdentifier("DisciplineViewCtrl") as! ischoolViewCtrl
        
        return v
    }
}

