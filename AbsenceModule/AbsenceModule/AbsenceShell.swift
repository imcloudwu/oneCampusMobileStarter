//
//  AbsenceShell.swift
//  SampleModule
//
//  Created by Cloud on 2016/3/7.
//  Copyright © 2016年 ischool. All rights reserved.
//

import Foundation
import ischoolFramework

public class AbsenceShell : ischoolProtocol{
    
    public static var Instance : ischoolProtocol{
        
        get{
            return AbsenceShell()
        }
    }
    
    public var Name : String{
        
        get{
            return "缺 曠 查 詢"
        }
    }
    
    public var Scopes : [String]{
        
        get{
            return ["1campus.mobile.parent"]
        }
    }
    
    public var Icon : UIImage?{
        
        get{
            return UIImage(named: "Expired Filled-50.png", inBundle: BundleId, compatibleWithTraitCollection: nil)
        }
    }
    
    public var BundleId : NSBundle?{
        
        get{
            return NSBundle(identifier: "tw.ischool.AbsenceModule")
        }
    }
    
    public var Storyboard : UIStoryboard?{
        
        get{
            return UIStoryboard(name: "Storyboard", bundle: BundleId)
        }
    }
    
    public func GetViewController() -> ischoolViewCtrl{
        
        let v = Storyboard?.instantiateViewControllerWithIdentifier("AbsenceViewCtrl") as! ischoolViewCtrl
        
        return v
    }
}
