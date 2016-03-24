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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        
        self.navigationItem.title = "\(appContext?.Dsns)#\(appContext?.Id)"
        
        label.text = "hello SampleViewController"
        
        LoadData()
        
    }
    
    func LoadData(){
        
        if let id = appContext?.Id where !id.isEmpty{
            
            appContext?.SendRequest(contract, srevice: "absence.GetChildAttendance", req: "<Request><RefStudentId>\(id)</RefStudentId></Request>", successCallback: { (response) -> () in
                
                print(response)
                
                self.label.text = response
                
                }, failureCallback: { (error) -> () in
                    
                    print(error)
            })
            
        }
    }
}



