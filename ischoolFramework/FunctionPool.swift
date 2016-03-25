//
//  FunctionPool.swift
//  ischoolFramework
//
//  Created by Cloud on 2016/3/7.
//  Copyright © 2016年 ischool. All rights reserved.
//

class FunctionPool{
    
    private var _pool : [ischoolProtocol]
    
    init(){
        
        _pool = [ischoolProtocol]()
    }
    
//    func GetPools() -> [ischoolProtocol]?{
//        
//        return _pool
//    }
    
    func GetFunctionsByIDs(ids:[String]) -> [ischoolProtocol]{
        
        var functions = [ischoolProtocol]()
        
        for id in ids{
            
            for f in _pool{
                
                if let bundleId = f.BundleId?.bundleIdentifier where bundleId == id{
                    
                    functions.append(f)
                }
            }
        }
        
        return functions
    }
    
    func GetAllFunctions() -> [ischoolProtocol]{
        
        return _pool
    }
    
    func AddFunction(function:ischoolProtocol){
    
        _pool.append(function)
    }
    
    func Clear(){
        
        _pool = [ischoolProtocol]()
    }
}