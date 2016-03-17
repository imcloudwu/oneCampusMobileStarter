//
//  DsnsManager.swift
//  ischoolFramework
//
//  Created by Cloud on 2016/3/17.
//  Copyright © 2016年 ischool. All rights reserved.
//

class DsnsManager{
    
    var DsnsList : [DsnsItem]!
    
    private static var _singleton : DsnsManager!
    
    static var Singleton : DsnsManager{
        
        get{
            
            if _singleton == nil{
                
                _singleton = DsnsManager()
            }
            
            return _singleton!
        }
    }
    
    func ClearDsnsList(){
        
        DsnsList = [DsnsItem]()
    }
    
    private init(){
        
        DsnsList = [DsnsItem]()
    }
    
}
