//
//  SemesterScoreShell.swift
//  SemesterScoreModule
//
//  Created by Cloud on 2016/3/16.
//  Copyright © 2016年 ischool. All rights reserved.
//

import Foundation
import ischoolFramework

public class SemesterScoreShell : ischoolProtocol{
    
    public static var Instance : ischoolProtocol{
        
        get{
            return SemesterScoreShell()
        }
    }
    
    public var Name : String{
        
        get{
            return "學 期 成 績"
        }
    }
    
    public var Scopes : [String]{
        
        get{
            return ["1campus.mobile.parent"]
        }
    }
    
    public var Icon : UIImage?{
        
        get{
            return UIImage(named: "Report Card Filled-50.png", inBundle: BundleId, compatibleWithTraitCollection: nil)
        }
    }
    
    public var BundleId : NSBundle?{
        
        get{
            return NSBundle(identifier: "tw.ischool.SemesterScoreModule")
        }
    }
    
    public var Storyboard : UIStoryboard?{
        
        get{
            return UIStoryboard(name: "Storyboard", bundle: BundleId)
        }
    }
    
    public func GetViewController() -> ischoolViewCtrl{
        
        let v = Storyboard?.instantiateViewControllerWithIdentifier("SemesterScoreViewCtrl") as! ischoolViewCtrl
        
        return v
    }
}

