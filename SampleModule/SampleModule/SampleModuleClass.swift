//
//  SampleModuleClass.swift
//  SampleModule
//
//  Created by Cloud on 2016/3/7.
//  Copyright © 2016年 ischool. All rights reserved.
//

import Foundation
import ischoolFramework

public class SampleShell : ischoolProtocol{
    
    public static var Instance : ischoolProtocol{
        
        get{
            return SampleShell()
        }
    }
    
    public var Name : String{
        
        get{
            return "SampleModule"
        }
    }
    
    public var Scope : String{
        
        get{
            return "1campus.mobile.parent"
        }
    }
    
    public var Icon : UIImage?{
        
        get{
            return UIImage(named: "Facebook Filled-50.png", inBundle: BundleId, compatibleWithTraitCollection: nil)
        }
    }
    
    public var BundleId : NSBundle?{
        
        get{
            return NSBundle(identifier: "tw.ischool.SampleModule")
        }
    }
    
    public var Storyboard : UIStoryboard?{
        
        get{
            return UIStoryboard(name: "Storyboard", bundle: BundleId)
        }
    }
    
    public func GetViewController() -> ischoolViewCtrl{
        
        let v = Storyboard?.instantiateViewControllerWithIdentifier("SampleViewController") as! ischoolViewCtrl
        
        return v
    }
}
