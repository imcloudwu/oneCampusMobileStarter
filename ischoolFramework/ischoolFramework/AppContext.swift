//
//  AppContext.swift
//  ischoolFramework
//
//  Created by Cloud on 2016/3/9.
//  Copyright © 2016年 ischool. All rights reserved.
//

public class AppContext{
    
    public var Identy : IdentityType?
    
    public var Dsns : String?
    
    public var Id : String?
    
    private var connection : ConnectionManager?
    
    public var delegate : InfoChangeDelegate?
    
    init(identy:IdentityType?,dsns:String?,id:String?,connectionManager:ConnectionManager?){
        
        self.Identy = identy
        
        self.Dsns = dsns
        
        self.Id = id
        
        self.connection = connectionManager
    }
    
    public func SendRequest(contract:String,srevice:String,req:String,callback:(response:String) -> ()){
        
        if let dsns = self.Dsns{
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                
                let rsp = self.connection?.SendRequest(dsns, contract: contract, service: srevice, body: req)
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    callback(response: rsp ?? "")
                })
            })
        }
    }
}

enum RequestError : ErrorType{
    
    case Whatever
}

public enum IdentityType: String{
    
    case Admin = "決策人員"
    case Teacher = "教師"
    case Parent = "家長"
    case Student = "學生"
}
