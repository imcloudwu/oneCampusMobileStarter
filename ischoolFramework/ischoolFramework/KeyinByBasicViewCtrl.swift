//
//  KeyinByBasicViewCtrl.swift
//  ischoolFramework
//
//  Created by Cloud on 2016/3/17.
//  Copyright © 2016年 ischool. All rights reserved.
//

import UIKit

class KeyinByBasicViewCtrl: UIViewController,UIAlertViewDelegate,UITextFieldDelegate,UIWebViewDelegate {
    
    let contract = "1campus.mobile.parent"
    
    @IBOutlet weak var selectSchoolBtn: UIButton!
    
    @IBOutlet weak var relationship: UITextField!
    
    @IBOutlet weak var idNumber: UITextField!
    
    @IBOutlet weak var studentNumber: UITextField!
    
    @IBOutlet weak var submitBtn: UIButton!
    
    var _DsnsItem : DsnsItem!
    
    var Resource : Resources!
    
    @IBAction func selectSchoolBtnClick(sender: AnyObject) {
        
        let nextView = self.storyboard?.instantiateViewControllerWithIdentifier("SelectSchoolViewCtrl") as! SelectSchoolViewCtrl
        
        nextView._SelectedSchool = _DsnsItem
        
        self.navigationController?.pushViewController(nextView, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        submitBtn.layer.masksToBounds = true
        submitBtn.layer.cornerRadius = 5
        
        relationship.delegate = self
        idNumber.delegate = self
        studentNumber.delegate = self
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        
        if _DsnsItem == nil{
            _DsnsItem = DsnsItem(name: "", accessPoint: "")
        }
        
        if _DsnsItem.AccessPoint.isEmpty{
            self.selectSchoolBtn.setTitle("選擇學校", forState: UIControlState.Normal)
        }
        else{
            self.selectSchoolBtn.setTitle(_DsnsItem.Name, forState: UIControlState.Normal)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // called when 'return' key pressed. return NO to ignore.
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        self.view.endEditing(true)
        
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func submit(sender: AnyObject) {
        
        let serverName = self._DsnsItem.AccessPoint
        
        if serverName.isEmpty{
            ShowErrorAlert(self, title: "請選擇學校", msg: "")
            return
        }
        
        if relationship.text!.isEmpty{
            ShowErrorAlert(self, title: "親子關係必須填寫", msg: "")
            return
        }
        
        if idNumber.text!.isEmpty{
            ShowErrorAlert(self, title: "身分證號必須填寫", msg: "")
            return
        }
        
        if studentNumber.text!.isEmpty{
            ShowErrorAlert(self, title: "學號必須填寫", msg: "")
            return
        }
        
        AddApplicationRef(serverName)
    }
    
    func AddApplicationRef(server:String){
        
        self._DsnsItem = DsnsItem(name: server, accessPoint: server)
        
        if !DsnsManager.Singleton.DsnsList.contains(self._DsnsItem){
            
            let _ = Resource.Connection.SendRequest("https://auth.ischool.com.tw:8443/dsa/greening", contract: "user", service: "AddApplicationRef", body: "<Request><Applications><Application><AccessPoint>\(server)</AccessPoint><Type>dynpkg</Type></Application></Applications></Request>")
            
            DsnsManager.Singleton.DsnsList.append(self._DsnsItem)
            
            Resource.Connection.loginHelper.TryToChangeScope(self, after: { () -> Void in
                
                self.JoinAsParent()
            })
        }
        else{
            
            JoinAsParent()
        }
    }
    
    func JoinAsParent(){
        
        if let relationship = self.relationship.text, let idNumber = self.idNumber.text, let studentNumber = self.studentNumber.text{
            
            let rsp1 = Resource.Connection.SendRequest(self._DsnsItem.AccessPoint, contract: "1campus.mobile.guest", service: "_.ConfirmMyChild", body: "<Request><StudentIdNumber>\(idNumber)</StudentIdNumber><StudentNumber>\(studentNumber)</StudentNumber></Request>")
            
            if rsp1.isEmpty{
                ShowErrorAlert(self, title: "該校查詢不到此學生資料,無法加入", msg: "")
                return
            }
            
            var xml: AEXMLDocument?
            do {
                xml = try AEXMLDocument(xmlData: rsp1.dataValue)
            } catch _ {
                xml = nil
            }
            
            var Id = ""
            var Name = ""
            
            if let id = xml?.root["Response"]["Id"].stringValue{
                Id = id
            }
            
            if let name = xml?.root["Response"]["Name"].stringValue{
                Name = name
            }
            
            if !Id.isEmpty && !Name.isEmpty{
                
                let confirm = UIAlertController(title: "您的小孩是 \(Name) 嗎？", message: "", preferredStyle: UIAlertControllerStyle.Alert)
                
                confirm.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
                confirm.addAction(UIAlertAction(title: "確認", style: UIAlertActionStyle.Destructive, handler: { (action) -> Void in
                    
                    let rsp2 = self.Resource.Connection.SendRequest(self._DsnsItem.AccessPoint, contract: "1campus.mobile.guest", service: "_.JoinAsParent", body: "<Request><StudentId>\(Id)</StudentId><Relationship>\(relationship)</Relationship></Request>")
                    
                    var xml: AEXMLDocument?
                    
                    do {
                        xml = try AEXMLDocument(xmlData: rsp2.dataValue)
                    } catch _ {
                        xml = nil
                    }
                    
                    if let msg = xml?.root["result"].stringValue where msg == "success"{
                        
                        let alert = UIAlertController(title: "加入成功", message: "", preferredStyle: UIAlertControllerStyle.Alert)
                        
                        alert.addAction(UIAlertAction(title: "確認", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                            
                            self.navigationController?.popViewControllerAnimated(true)
                        }))
                        
                        self.presentViewController(alert, animated: true, completion: nil)
                        
                    }
                    else{
                        ShowErrorAlert(self, title: "加入失敗", msg: "發生不明的錯誤,請回報給開發人員")
                    }
                    
                }))
                
                self.presentViewController(confirm, animated: true, completion: nil)
            }
            else{
                
                ShowErrorAlert(self, title: "該校查詢不到此學生資料,無法加入", msg: "")
                return
            }
        }
        
    }
}