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
    
    public init(clientId:String,clientSecret:String,url:String){
        
        self.accountInfo = AccountInfo()
        
        self.clientId = clientId
        
        self.clientSecret = clientSecret
        
        self.url = url
        
        self.lockQueue = dispatch_queue_create("LoginHelper.lockQueue", nil)
    }
    
    private func GetLoginView() -> UIViewController{
        
        let view = frameworkStoryboard.instantiateViewControllerWithIdentifier("LoginView") as! CustomNavigationView
        
        view.loginHelper = self
        
        return view
    }
    
    public func TryToLogin(parent:UIViewController,success:(() -> Void)){
        
        if self.AccessToken.isEmpty{
            
            if let refreshToken = Keychain.load(saveKey)?.stringValue where !refreshToken.isEmpty{
                
                self.RenewRefreshToken(refreshToken)
                
                if self.AccessToken.isEmpty{
                    
                    parent.presentViewController(self.GetLoginView(), animated: true, completion: nil)
                }
                else{
                    
                    success()
                }
            }
            else{
                
                parent.presentViewController(self.GetLoginView(), animated: true, completion: nil)
            }
        }
        else{
            
            success()
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
    
}
