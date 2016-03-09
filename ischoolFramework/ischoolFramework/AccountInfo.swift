//
//  AccountInfo.swift
//  ischoolFramework
//
//  Created by Cloud on 2016/3/8.
//  Copyright © 2016年 ischool. All rights reserved.
//

class AccountInfo{
    
    private var myPhotoLocalPath = NSHomeDirectory().stringByAppendingString("/Documents/myPhoto.dat")
    
    var Name : String = ""
    
    var Account : String = ""
    
    var MyPhoto : UIImage?{
        
        get{
            
            let fm = NSFileManager()
            
            if fm.fileExistsAtPath(myPhotoLocalPath){
                
                return UIImage(contentsOfFile: myPhotoLocalPath)
            }
            else{
                
                return UIImage(named: "default photo.jpg")
            }
            
        }
    }
    
    func SetInfo(accessToken:String){
        
        let rsp1 = try? HttpClient.Get("https://auth.ischool.com.tw/services/me.php?access_token=\(accessToken)")
        
        //println(NSString(data: rsp!, encoding: NSUTF8StringEncoding))
        
        if let data = rsp1{
            
            let json = JSON(data: data)
            
            Name = json["firstName"].stringValue + " " + json["lastName"].stringValue
            
            Account = json["mail"].stringValue
        }
        
        let rsp2 = try? HttpClient.Get("https://auth.ischool.com.tw/service/getpic.php")
        
        if let data = rsp2{
            
            let image = UIImage(data: data)
            
            let imgData = UIImageJPEGRepresentation(image!, 0.5)
            
            imgData?.writeToFile(myPhotoLocalPath, atomically: true)
        }
        
    }
}
