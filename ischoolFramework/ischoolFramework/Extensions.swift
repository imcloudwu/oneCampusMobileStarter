//
//  Extensions.swift
//  CommonTool
//
//  Created by Cloud on 2016/3/2.
//  Copyright © 2016年 ischool. All rights reserved.
//

extension NSData {
    public var stringValue: String {
        return NSString(data: self, encoding: NSUTF8StringEncoding)! as String
    }
}

//if failed will return 0
extension String {
    
    var intValue: Int {
        return Int(self) ?? 0
    }
    
    var int16Value: Int16 {
        return Int16(self.intValue)
    }
    
    var doubleValue: Double {
        return (self as NSString).doubleValue
    }
    
    public var dataValue: NSData {
        return self.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
    }
    
    public var UrlEncoding: String?{
        return self.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
    }
    
    //    public var UrlDecoding: String?{
    //
    //        let sEncode = self.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
    //
    //        return sEncode?.stringByRemovingPercentEncoding
    //    }
    
    func PadLeft(leng:Int,str:String) -> String{
        
        if (self as NSString).length < leng {
            let l = leng - (self as NSString).length
            
            var s = ""
            
            for _ in 0...l{
                s += str
            }
            
            return s + self
        }
        
        return self
    }
}