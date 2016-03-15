//
//  SampleViewController
//  oneCampusMobileStarter
//
//  Created by Cloud on 2016/3/1.
//  Copyright © 2016年 ischool. All rights reserved.
//

import UIKit
import ischoolFramework

class SampleViewController: ischoolViewCtrl {
    
    let contract = "1campus.mobile.parent"
    
    @IBOutlet weak var label: UILabel!
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        passValue?.delegate = self
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        
        self.navigationItem.title = "\(appContext?.Dsns)#\(appContext?.Id)"
        
        label.text = "hello SampleViewController"
        
        LoadData()
        
    }
    
    override func DsnsChanged(dsns: String) {
        
        appContext?.Dsns = dsns
        
        print("DsnsChanged")
        
        LoadData()
        
        self.navigationItem.title = "\(appContext?.Dsns)#\(appContext?.Id)"
    }
    
    override func StudentIdChanged(studentId: String) {
        
        appContext?.Id = studentId
        
        print("StudentIdChanged")
        
        LoadData()
        
        self.navigationItem.title = "\(appContext?.Dsns)#\(appContext?.Id)"
    }
    
    func LoadData(){
        
        if let id = appContext?.Id where !id.isEmpty{
            
            appContext?.SendRequest(contract, srevice: "absence.GetChildAttendance", req: "<Request><RefStudentId>\(id)</RefStudentId></Request>", callback: { (response) -> () in
                
                print(response)
                
                self.label.text = response
            })
            
        }
    }
}



