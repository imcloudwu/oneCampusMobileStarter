//
//  ExamScoreShell.swift
//  ExamScoreModule
//
//  Created by Cloud on 2016/3/15.
//  Copyright © 2016年 ischool. All rights reserved.
//

import Foundation
import ischoolFramework

public class ExamScoreShell : ischoolProtocol{
    
    public static var Instance : ischoolProtocol{
        
        get{
            return ExamScoreShell()
        }
    }
    
    public var Name : String{
        
        get{
            return "評 量 成 績"
        }
    }
    
    public var Scope : String{
        
        get{
            return "1campus.mobile.parent"
        }
    }
    
    public var Icon : UIImage?{
        
        get{
            return UIImage(named: "Exam Filled-50.png", inBundle: BundleId, compatibleWithTraitCollection: nil)
        }
    }
    
    public var BundleId : NSBundle?{
        
        get{
            return NSBundle(identifier: "tw.ischool.ExamScoreModule")
        }
    }
    
    public var Storyboard : UIStoryboard?{
        
        get{
            return UIStoryboard(name: "Storyboard", bundle: BundleId)
        }
    }
    
    public func GetViewController() -> ischoolViewCtrl{
        
        let v = Storyboard?.instantiateViewControllerWithIdentifier("ExamScoreViewCtrl") as! ischoolViewCtrl
        
        return v
    }
}

