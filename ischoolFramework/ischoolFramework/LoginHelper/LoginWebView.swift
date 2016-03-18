//
//  LoginWebView.swift
//  LoginHelper
//
//  Created by Cloud on 2016/3/2.
//  Copyright © 2016年 ischool. All rights reserved.
//

import UIKit

class LoginWebView : UIViewController,UIWebViewDelegate{
    
    var cnv : CustomNavigationView?
    
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cnv = self.navigationController as? CustomNavigationView
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "ReloadWebPage")
        
        webView.delegate = self
        
        self.ReloadWebPage()
    }
    
    func ReloadWebPage(){
        
        //載入登入頁面
        if let target = cnv?.url{
            
            let urlobj = NSURL(string: target)
            let request = NSURLRequest(URL: urlobj!)
            webView.loadRequest(request)
        }
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?){
        
        //網路異常
        if error!.code == -1009{
            
            if let code = GetCodeFromError(error!){
                SetTokenAndClose(code)
            }
            else{
                let alert = UIAlertController(title: "網路無法連線", message: "請點選右上方的重新整理", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
        
        //取得code
        if error!.domain == "NSURLErrorDomain" && error!.code == -1003{
            
            if let code = GetCodeFromError(error!){
                SetTokenAndClose(code)
            }
        }
    }
    
    func GetCodeFromError(error: NSError) -> String?{
        
        if let url = error.userInfo["NSErrorFailingURLStringKey"] as? String{
            if let range = url.rangeOfString("http://_blank/?state=http%3A%2F%2F_blank&code="){
                var code = url
                code.removeRange(range)
                
                //println(code)
                
                return code
            }
        }
        
        return nil
    }
    
    func SetTokenAndClose(code:String){
        
        cnv?.loginHelper?.accountInfo.SaveUserImage()
        
        DeleteCatch()
        
        cnv?.loginHelper?.GetAccessTokenAndRefreshToken(code)
        
        self.dismissViewControllerAnimated(true) { () -> Void in
            self.cnv?.after?()
        }
    }
    
    func DeleteCatch(){
        
        NSURLCache.sharedURLCache().removeAllCachedResponses()
        
        let storage : NSHTTPCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        
        for cookie in storage.cookies!
        {
            storage.deleteCookie(cookie)
        }
    }
    
}


