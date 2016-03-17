//
//  SlideViewFactory
//  ischoolFramework
//
//  Created by Cloud on 2016/3/4.
//  Copyright © 2016年 ischool. All rights reserved.
//

public class SlideView{
    
    private static var _mmdc : MMDrawerController?
    
    static var _window : UIWindow?
    
    static var _root : UIViewController?
    
    public class func GetInstance(resource:Resources) -> MMDrawerController?{
        
        DsnsManager.Singleton.ClearDsnsList()
        
        let leftView = frameworkStoryboard.instantiateViewControllerWithIdentifier("LeftView") as! LeftViewCtrl
        
        leftView.Resource = resource
        
        let rightView = frameworkStoryboard.instantiateViewControllerWithIdentifier("RightView") as! UINavigationController
        
        _mmdc = MMDrawerController(centerViewController: rightView, leftDrawerViewController: leftView)
        
        _mmdc?.openDrawerGestureModeMask = MMOpenDrawerGestureMode.PanningCenterView
        
        _mmdc?.closeDrawerGestureModeMask = [MMCloseDrawerGestureMode.PanningCenterView, MMCloseDrawerGestureMode.TapCenterView]
        
        return _mmdc
    }
    
    public class func ChangeContentView(vc:UIViewController){
        
        //GetInstance()?.setCenterViewController(vc, withCloseAnimation: true, completion: nil)
        
        let nvc = _mmdc?.centerViewController as? UINavigationController
        
        nvc?.setViewControllers([vc], animated: true)
        
        _mmdc?.closeDrawerAnimated(true, completion: nil)
    }
    
    public class func EnableSideMenu(){
        
        _mmdc?.openDrawerGestureModeMask = MMOpenDrawerGestureMode.PanningCenterView
        
        _mmdc?.closeDrawerGestureModeMask = [MMCloseDrawerGestureMode.PanningCenterView, MMCloseDrawerGestureMode.TapCenterView]
    }
    
    public class func DisableSideMenu(){
        
        _mmdc?.openDrawerGestureModeMask = MMOpenDrawerGestureMode.None
        
        _mmdc?.closeDrawerGestureModeMask = MMCloseDrawerGestureMode.None
    }
    
    public class func ToggleSideMenu(){
        
        _mmdc?.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
    }
}
