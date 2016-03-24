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
    
    public var Data : Student?
    
    private var connection : ConnectionManager?
    
    //public var delegate : InfoChangeDelegate?
    
    init(identy:IdentityType?,dsns:String?,id:String?,data:Student?,connectionManager:ConnectionManager?){
        
        self.Identy = identy
        
        self.Dsns = dsns
        
        self.Id = id
        
        self.Data = data
        
        self.connection = connectionManager
    }
    
    public func SendRequest(contract:String,srevice:String,req:String,successCallback:(response:String) -> (),failureCallback:(error:String) -> ()){
        
        if let dsns = self.Dsns{
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                
                do{
                    
                    let rsp = try self.connection?.SendRequest(dsns, contract: contract, service: srevice, body: req)
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        successCallback(response: rsp ?? "")
                    })
                    
                }
                catch ConnectionError.connectError(let reason){
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        failureCallback(error:reason)
                    })
                    
                }
                catch{
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        failureCallback(error:"未知的錯誤")
                    })
                    
                }
                
            })
        }
    }
}

public enum IdentityType: String{
    
    case Admin = "決策人員"
    case ClassTeacher = "班導師"
    case CourseTeacher = "授課老師"
    case Parent = "家長"
    case Student = "學生"
}
