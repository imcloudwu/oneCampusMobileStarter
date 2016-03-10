//
//  Resources.swift
//  ischoolFramework
//
//  Created by Cloud on 2016/3/8.
//  Copyright © 2016年 ischool. All rights reserved.
//

public class Resources{
    
    var Functions : FunctionPool
    
    var Connection : ConnectionManager
    
    public init(connectionManager:ConnectionManager){
        
        self.Connection = connectionManager
        
        self.Functions = FunctionPool()
    }
    
    public func AddFunction(function:ischoolProtocol){
        
        self.Functions.AddFunction(function)
    }
}
