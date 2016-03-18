//
//  DsnsManager.swift
//  ischoolFramework
//
//  Created by Cloud on 2016/3/17.
//  Copyright © 2016年 ischool. All rights reserved.
//

class DsnsManager{
    
    private var dsnsList : [DsnsItem]!
    
    private static var _singleton : DsnsManager!
    
    static var Singleton : DsnsManager{
        
        get{
            
            if _singleton == nil{
                
                _singleton = DsnsManager()
            }
            
            return _singleton!
        }
    }
    
    var DsnsList : [DsnsItem]{
        
        get{
            
            if dsnsList == nil{
                
                dsnsList = [DsnsItem]()
            }
            
            return dsnsList
        }
        
        set(value){
            
            dsnsList = value
        }
        
    }
    
    func ClearDsnsList(){
        
        dsnsList = [DsnsItem]()
    }
    
    private init(){
        
        dsnsList = [DsnsItem]()
    }
    
}

public class DsnsItem : Equatable{
    
    public var Name : String
    public var AccessPoint : String
    public var Location : String
    public var Type : String
    
    public init(name:String,accessPoint:String){
        self.Name = name
        self.AccessPoint = accessPoint
        self.Location = ""
        self.Type = ""
    }
}

public func ==(lhs: DsnsItem, rhs: DsnsItem) -> Bool {
    return lhs.AccessPoint == rhs.AccessPoint
}
