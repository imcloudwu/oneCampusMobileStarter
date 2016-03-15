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
import DisciplineModule
import ExamScoreModule

class EnterViewController : UIViewController{
    
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    var loginHelper : LoginHelper!
    
    var modules = [ExamScoreShell.Instance,DisciplineShell.Instance,AbsenceShell.Instance,SampleShell.Instance,SampleShell.Instance,SampleShell.Instance]
    
    //var modules = [ischoolProtocol]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Keychain.clear()
        
        //Keychain.save("refreshToken", data: "1234".dataValue)
        
        loginHelper = LoginHelper(clientId: clientID, clientSecret: clientSecret, url: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        
        let scope = "User.Mail,User.BasicInfo,1Campus.Notification.Read,1Campus.Notification.Send,*:auth.guest,*:sakura" + GetScopes()
        
        let url = "https://auth.ischool.com.tw/oauth/authorize.php?client_id=\(clientID)&response_type=code&state=http://_blank&redirect_uri=http://_blank&scope=\(scope)"
        
        loginHelper.SetUrl(url)
        
        loginHelper.TryToLogin(self, success: PrepareGotoMainView)
    }
    
    override func viewWillAppear(animated: Bool) {
        
        loading.startAnimating()
    }
    
    override func viewDidDisappear(animated: Bool) {
        
        loading.stopAnimating()
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
        
        self.presentViewController(SlideView.GetInstance(resources)!, animated: true, completion: nil)
        
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


