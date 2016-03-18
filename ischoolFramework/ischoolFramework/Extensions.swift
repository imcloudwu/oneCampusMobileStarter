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
    
    public var intValue: Int {
        return Int(self) ?? 0
    }
    
    public var int16Value: Int16 {
        return Int16(self.intValue)
    }
    
    public var doubleValue: Double {
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

extension UITableView{
    
    public func reloadDataWithAnimated(){
        
        self.reloadData()
        
        animatedWithTableView(self)
    }
    
    private func animatedWithTableView(tableView:UITableView){
        
        let cells = tableView.visibleCells
        let tableHeight: CGFloat = tableView.bounds.size.height
        
        for cell in cells{
            cell.transform = CGAffineTransformMakeTranslation(0, tableHeight)
        }
        
        var index = 0
        
        for cell in cells {
            
            UIView.animateWithDuration(1.0, delay: 0.05 * Double(index), usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
                cell.transform = CGAffineTransformMakeTranslation(0, 0);
                }, completion: nil)
            
            index += 1
        }
    }
}

//回傳一張縮放後的圖片
extension UIImage{
    func GetResizeImage(scale:CGFloat) -> UIImage{
        
        let width = self.size.width
        let height = self.size.height
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(width * scale, height * scale), false, 1)
        self.drawInRect(CGRectMake(0, 0, width * scale, height * scale))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func GetResizeImage(width:CGFloat, height:CGFloat) -> UIImage{
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), false, 1)
        self.drawInRect(CGRectMake(0, 0, width, height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return newImage
    }
}

