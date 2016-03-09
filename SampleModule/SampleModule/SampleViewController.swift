//
//  SampleViewController
//  oneCampusMobileStarter
//
//  Created by Cloud on 2016/3/1.
//  Copyright © 2016年 ischool. All rights reserved.
//

import UIKit
import ischoolFramework

class SampleViewController: ischoolViewCtrl,InfoChangeDelegate {
    
    let contract = "1campus.mobile.parent"
    
    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        passValue?.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        
        self.navigationItem.title = "\(passValue?.Dsns)#\(passValue?.Id)"
        
        label.text = "hello SampleViewController"
        
        LoadData()
        
    }
    
    func DsnsChanged(dsns: String) {
        
        passValue?.Dsns = dsns
        
        print("DsnsChanged")
        
        LoadData()
        
        self.navigationItem.title = "\(passValue?.Dsns)#\(passValue?.Id)"
    }
    
    func StudentIdChanged(studentId: String) {
        
        passValue?.Id = studentId
        
        print("StudentIdChanged")
        
        LoadData()
        
        self.navigationItem.title = "\(passValue?.Dsns)#\(passValue?.Id)"
    }
    
    func LoadData(){
        
        if let id = passValue?.Id where !id.isEmpty{
            
            passValue?.SendRequest(contract, srevice: "absence.GetChildAttendance", req: "<Request><RefStudentId>\(id)</RefStudentId></Request>", callback: { (response) -> () in
                
                print(response)
                
                self.label.text = response
            })
            
        }
    }
}



