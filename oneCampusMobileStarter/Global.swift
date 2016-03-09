//
//  Global.swift
//  oneCampusMobileStarter
//
//  Created by Cloud on 2016/3/2.
//  Copyright © 2016年 ischool. All rights reserved.
//

import Foundation
import ischoolFramework

let clientID = "e6228b759e6ca00c620a1f9a1171745d"
let clientSecret = "070575826e01ae4396d244b2ebb463491c447634068657eb3cb20d01a3b96fdd"
let contractName = "1campus.mobile.parent"



//func GetMyAccountInfo(){
//
//    Global.MyName = "My name"
//    Global.MyEmail = "My e-mail"
//
//    let rsp = try? HttpClient.Get("https://auth.ischool.com.tw/services/me.php?access_token=\(Global.AccessToken)")
//
//    //println(NSString(data: rsp!, encoding: NSUTF8StringEncoding))
//    
//    if let data = rsp{
//        
//        let json = JSON(data: data)
//        
//        Global.MyName = json["firstName"].stringValue + " " + json["lastName"].stringValue
//        Global.MyEmail = json["mail"].stringValue
//    }
//}
