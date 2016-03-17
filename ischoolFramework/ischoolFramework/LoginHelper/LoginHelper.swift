//
//  LoginHelper.swift
//  LoginHelper
//
//  Created by Cloud on 2016/3/1.
//  Copyright © 2016年 ischool. All rights reserved.
//

import Foundation

public class LoginHelper{
    
    let saveKey = "refreshToken"
    
    var accountInfo : AccountInfo
    
    var url : String?
    
    var clientId : String?
    
    var clientSecret : String?
    
    var accessToken : String?
    
    var refreshToken : String?
    
    private var lockQueue : dispatch_queue_t
    
    public var AccessToken : String{
        
        if let token = accessToken{
            return token
        }
        
        return ""
    }
    
    public var RefreshToken : String{
        
        if let token = refreshToken{
            return token
        }
        
        return ""
    }
    
    public init(clientId:String,clientSecret:String,url:String?){
        
        self.accountInfo = AccountInfo()
        
        self.clientId = clientId
        
        self.clientSecret = clientSecret
        
        self.url = url
        
        self.lockQueue = dispatch_queue_create("LoginHelper.lockQueue", nil)
    }
    
    public func SetUrl(url:String){
    
        self.url = url
    }
    
    private func GetLoginView(url:String?) -> UIViewController{
        
        return GetLoginView(url,after:nil)
    }
    
    private func GetLoginView(url:String?,after:(() -> Void)?) -> UIViewController{
        
        let view = frameworkStoryboard.instantiateViewControllerWithIdentifier("LoginView") as! CustomNavigationView
        
        view.loginHelper = self
        
        view.url = url
        
        view.after = after
        
        return view
    }
    
    public func TryToLogin(parent:UIViewController,success:(() -> Void)){
        
        if self.AccessToken.isEmpty{
            
            if let refreshToken = Keychain.load(saveKey)?.stringValue where !refreshToken.isEmpty{
                
                self.RenewRefreshToken(refreshToken)
                
                if self.AccessToken.isEmpty{
                    
                    parent.presentViewController(self.GetLoginView(self.url), animated: true, completion: nil)
                }
                else{
                    
                    success()
                }
            }
            else{
                
                parent.presentViewController(self.GetLoginView(self.url), animated: true, completion: nil)
            }
        }
        else{
            
            success()
        }
        
    }
    
    public func TryToChangeScope(parent:UIViewController,after:(() -> Void)){
        
        if let url = self.url{
            
            let new_url = url + "&access_token=\(self.AccessToken)"
            
            let view = self.GetLoginView(new_url, after: after)
            
            parent.presentViewController(view, animated: true, completion: nil)
        }
    }
    
    public func GetAccessTokenAndRefreshToken(code:String){
        
        dispatch_sync(lockQueue) {
            
            if let clientId = self.clientId , let clientSecret = self.clientSecret{
                
                let oautHelper = OAuthHelper(clientId: clientId, clientSecret: clientSecret)
                
                let token = try? oautHelper.getAccessTokenAndRefreshToken(code)
                
                self.accessToken = token?.0
                
                self.refreshToken = token?.1
                
                self.SaveRefreshToken()
            }
        }
    }
    
    public func RenewRefreshToken(refreshToken:String){
        
        dispatch_sync(lockQueue) {
            
            if let clientId = self.clientId , let clientSecret = self.clientSecret{
                
                let oautHelper = OAuthHelper(clientId: clientId, clientSecret: clientSecret)
                
                let token = try? oautHelper.renewAccessToken(refreshToken)
                
                self.accessToken = token?.0
                
                self.refreshToken = token?.1
                
                self.SaveRefreshToken()
            }
        }
    }
    
    func SaveRefreshToken(){
        
        if let rftoken = self.refreshToken{
            
            Keychain.save(saveKey, data: rftoken.dataValue)
        }
    }
    
    func CleanAccessTokenAndRefreshToken(){
        
        self.accessToken = nil
        
        self.refreshToken = nil
        
        Keychain.delete(saveKey)
    }
    
}
