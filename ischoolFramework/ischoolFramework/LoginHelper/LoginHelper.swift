//
//  LoginHelper.swift
//  LoginHelper
//
//  Created by Cloud on 2016/3/1.
//  Copyright © 2016年 ischool. All rights reserved.
//

import Foundation

public class LoginHelper{
    
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
        self.clientId = clientId
        self.clientSecret = clientSecret
        self.url = url
        self.lockQueue = dispatch_queue_create("LoginHelper.lockQueue", nil)
    }
    
    public func GetLoginView() -> UIViewController{
        
        let view = frameworkStoryboard.instantiateViewControllerWithIdentifier("LoginView") as! CustomNavigationView
        
        view.loginHelper = self
        
        return view
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
            
            Keychain.save("refreshToken", data: rftoken.dataValue)
        }
    }
}
