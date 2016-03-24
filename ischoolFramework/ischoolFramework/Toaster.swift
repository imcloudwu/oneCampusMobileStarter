//
//  Toaster.swift
//  ischoolFramework
//
//  Created by Cloud on 2016/3/23.
//  Copyright © 2016年 ischool. All rights reserved.
//

public class Toaster {
    
    var container: UIView = UIView()
    var Message: UILabel = UILabel()
    
    private static var sharedInstance = Toaster()
    
    func ShowMessage(uiView: UIView,msg:String) {
        
        Message.text = msg
        Message.alpha = 1
        Message.textColor = UIColor.whiteColor()
        Message.textAlignment = NSTextAlignment.Center
        Message.frame = CGRectMake(0, 0, 200, 50)
        Message.center = uiView.center
        Message.backgroundColor = UIColorFromHex(0x444444, alpha: 0.7)
        Message.layer.masksToBounds = true
        Message.layer.cornerRadius = 10
        
        uiView.addSubview(Message)
    }
    
    /*
    Show customized activity indicator,
    actually add activity indicator to passing view
    
    @param uiView - add activity indicator to this view
    */
    public static func ToastMessage(uiView: UIView,msg:String,time:Double,callback:(() -> ())?) {
        
        sharedInstance.ShowMessage(uiView,msg:msg)
        
        UIView.animateWithDuration(time, animations: { () -> Void in
            
            sharedInstance.Message.alpha = 0
            
            }) { (success) -> Void in
                
                sharedInstance.Message.removeFromSuperview()
                
                if let call = callback{
                    
                    call()
                }
        }
    }
    
    /*
    Define UIColor from hex value
    
    @param rgbValue - hex color value
    @param alpha - transparency level
    */
    func UIColorFromHex(rgbValue:UInt32, alpha:Double=1.0)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
    
}
