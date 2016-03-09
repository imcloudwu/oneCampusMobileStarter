//
//  EnterViewController.swift
//  oneCampusMobileStarter
//
//  Created by Cloud on 2016/3/4.
//  Copyright © 2016年 ischool. All rights reserved.
//

import UIKit
import ischoolFramework
import SampleModule

class EnterViewController : UIViewController{
    
    var loginHelper : LoginHelper!
    
    var modules = [SampleShell.Instance,SampleShell.Instance,SampleShell.Instance]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Keychain.clear()
        
        var scopes = [String]()
        
        for module in modules{
            
            let key = "*:" + module.Scope
            
            if !scopes.contains(key){
                scopes.append(key)
            }
        }
        
        let scope = "User.Mail,User.BasicInfo,1Campus.Notification.Read,1Campus.Notification.Send,*:auth.guest,*:sakura," + scopes.joinWithSeparator(",")
        
        let url = "https://auth.ischool.com.tw/oauth/authorize.php?client_id=\(clientID)&response_type=code&state=http://_blank&redirect_uri=http://_blank&scope=\(scope)"
        
        loginHelper = LoginHelper(clientId: clientID, clientSecret: clientSecret, url: url)
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if let refreshToken = Keychain.load("refreshToken")?.stringValue where !refreshToken.isEmpty{
            
            loginHelper.RenewRefreshToken(refreshToken)
            
            PrepareGotoMainView()
            
        }
        else if !loginHelper.AccessToken.isEmpty && !loginHelper.RefreshToken.isEmpty{
            
            PrepareGotoMainView()
            
        }
        else{
            
            self.presentViewController(loginHelper.GetLoginView(), animated: true, completion: nil)
        }
        
    }
    
    func PrepareGotoMainView(){
        
        GotoMainView()
    }
    
    func GotoMainView(){
        
        let connectionManager = ConnectionManager(loginHelper: loginHelper)
        
        let resources = Resources(connectionManager: connectionManager)
        
        for module in modules{
            
            resources.AddFunction(module)
        }
        
        let app = UIApplication.sharedApplication().delegate as! AppDelegate
        
        app.window?.rootViewController = SlideView.GetInstance(resources)
        
        app.window?.makeKeyAndVisible()
        
    }
    
    
}

