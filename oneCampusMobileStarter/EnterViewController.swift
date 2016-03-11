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
import AbsenceModule

class EnterViewController : UIViewController{
    
    var loginHelper : LoginHelper!
    
    var modules = [AbsenceShell.Instance,SampleShell.Instance,SampleShell.Instance,SampleShell.Instance]
    
    //var modules = [ischoolProtocol]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Keychain.clear()
        
        //Keychain.save("refreshToken", data: "1234".dataValue)
        
        let scope = "User.Mail,User.BasicInfo,1Campus.Notification.Read,1Campus.Notification.Send,*:auth.guest,*:sakura" + GetScopes()
        
        let url = "https://auth.ischool.com.tw/oauth/authorize.php?client_id=\(clientID)&response_type=code&state=http://_blank&redirect_uri=http://_blank&scope=\(scope)"
        
        loginHelper = LoginHelper(clientId: clientID, clientSecret: clientSecret, url: url)
    }
    
    override func viewDidAppear(animated: Bool) {
        
        loginHelper.TryToLogin(self, success: PrepareGotoMainView)
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
        
        app.window?.rootViewController = SlideView.GetInstance(resources) { () -> () in
            
            Keychain.clear()
            
            app.window?.rootViewController = self.storyboard?.instantiateViewControllerWithIdentifier("EnterViewController")
        }
        
        app.window?.makeKeyAndVisible()
        
    }
    
    func GetScopes() -> String{
        
        var scopes = [String]()
        
        for module in modules{
            
            let key = "*:" + module.Scope
            
            if !scopes.contains(key){
                
                scopes.append(key)
            }
        }
        
        let retval = scopes.joinWithSeparator(",")
        
        return retval.isEmpty ? "" : "," + retval
    }
    
    
}


