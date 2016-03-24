//
//  ConnectionManager.swift
//  ischoolFramework
//
//  Created by Cloud on 2016/3/8.
//  Copyright © 2016年 ischool. All rights reserved.
//

public class ConnectionManager{
    
    var connections : [String:Connection]
    
    var loginHelper : LoginHelper
    
    private var lockQueue : dispatch_queue_t
    
    public init(loginHelper:LoginHelper){
        
        self.connections = [String:Connection]()
        
        self.loginHelper = loginHelper
        
        lockQueue = dispatch_queue_create("ConnectionManager.lockQueue", nil)
    }
    
    public func SendRequest(dsns:String,contract:String,service:String,body:String) throws -> String{
        
        var err : DSFault!
        
        let con = GetConnection(dsns,contract)
        
        var rsp = con.sendRequest(service, bodyContent: body, &err)
        
        dispatch_sync(lockQueue) {
            
            if err != nil{
                
                err = nil
                
                self.loginHelper.RenewRefreshToken(self.loginHelper.RefreshToken)
                
                con.connect(dsns, contract, SecurityToken.createOAuthToken(self.loginHelper.AccessToken), &err)
                
                rsp = con.sendRequest(service, bodyContent: body, &err)
            }
            
        }
        
        if err != nil{
            throw ConnectionError.connectError(reason: err.message)
        }
        
        return rsp
    }
    
    func GetConnection(dsns:String,_ contract:String) -> Connection{
        
        let key = GetKey([dsns,contract])
        
        dispatch_sync(lockQueue) {
            
            if self.connections[key] == nil {
                
                var err: DSFault!
                
                let con = Connection()
                
                con.connect(dsns, contract, SecurityToken.createOAuthToken(self.loginHelper.AccessToken), &err)
                
                self.connections[key] = con
                
                if err != nil{
                    //ShowErrorAlert(vc,"錯誤來自:\(dsns)",err.message)
                }
            }
        }
        
        return self.connections[key]!
    }
    
    func GetKey(pramas:[String]) -> String{
        
        return pramas.joinWithSeparator("#")
    }
}

enum ConnectionError: ErrorType {
    case connectError(reason:String)
}
