//
//  AbsenceViewCtrl.swift
//  AbsenceModule
//
//  Created by Cloud on 2016/3/10.
//  Copyright © 2016年 ischool. All rights reserved.
//

import UIKit
import ischoolFramework

class AbsenceViewCtrl : ischoolViewCtrl{
    
    let contract = "1campus.mobile.parent"
    
    @IBOutlet weak var label: UILabel!
    
    func LoadData(){
        
        if let id = passValue?.Id where !id.isEmpty{
            
            passValue?.SendRequest(contract, srevice: "absence.GetChildAttendance", req: "<Request><RefStudentId>\(id)</RefStudentId></Request>", callback: { (response) -> () in
                
                print(response)
                
                self.label.text = response
            })
            
        }
    }
    
    func SetTitle() {
        
        var title = ""
        
        if let dsns = passValue?.Dsns{
            title += dsns
        }
        
        if let id = passValue?.Id{
            
            if !title.isEmpty{
                title += "#"
            }
            
            title += id
        }
        
        self.navigationItem.title = title
    }
    
    override func viewWillAppear(animated: Bool) {
        
        //self.navigationItem.title = "缺 曠 查 詢"
        
        LoadData()
    }
    
    override func StudentIdChanged(studentId: String) {
        
        passValue?.Id = studentId
        
        SetTitle()
        
        LoadData()
    }
    
    override func DsnsChanged(dsns: String) {
        
        passValue?.Dsns = dsns
        
        SetTitle()
        
        LoadData()
    }
}