//
//  AsTeacherViewCtrl.swift
//  oneAdminTeacher
//
//  Created by Cloud on 2016/1/28.
//  Copyright © 2016年 ischool. All rights reserved.
//

import UIKit

class AsTeacherViewCtrl: ischoolViewCtrl,UITextFieldDelegate,UIWebViewDelegate {
    
    var Resource : Resources!
    
    var _DsnsItem : DsnsItem!
    
    @IBOutlet weak var selectSchoolBtn: UIButton!
    
    @IBOutlet weak var codeTextField: UITextField!
    
    @IBAction func selectSchoolBtnClick(sender: AnyObject) {
        
        let nextView = self.storyboard?.instantiateViewControllerWithIdentifier("SelectSchoolViewCtrl") as! SelectSchoolViewCtrl
        
        nextView._SelectedSchool = _DsnsItem
        
        self.navigationController?.pushViewController(nextView, animated: true)
    }
    
    override func viewWillAppear(animated: Bool) {
        
        codeTextField.delegate = self
        
        self.navigationItem.title = "新 增 班 級"
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if _DsnsItem == nil{
            _DsnsItem = DsnsItem(name: "選擇學校", accessPoint: "")
        }
        
        selectSchoolBtn.setTitle(_DsnsItem.Name, forState: UIControlState.Normal)
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
    
    @IBAction func Submit(sender: AnyObject) {
        
        if self._DsnsItem.AccessPoint.isEmpty{
            ShowErrorAlert(self, title: "請選擇學校", msg: "")
            return
        }
        
        if let code = self.codeTextField.text where code.isEmpty{
            ShowErrorAlert(self, title: "請輸入教師代碼", msg: "")
            return
        }
        
        AddApplicationRef(self._DsnsItem.AccessPoint)
    }
    
    func AddApplicationRef(server:String){
        
        self._DsnsItem = DsnsItem(name: server, accessPoint: server)
        
        if !DsnsManager.Singleton.DsnsList.contains(self._DsnsItem){
            
            let _ = try? Resource.Connection.SendRequest("https://auth.ischool.com.tw:8443/dsa/greening", contract: "user", service: "AddApplicationRef", body: "<Request><Applications><Application><AccessPoint>\(server)</AccessPoint><Type>dynpkg</Type></Application></Applications></Request>")
            
            DsnsManager.Singleton.DsnsList.append(self._DsnsItem)
            
            Resource.Connection.loginHelper.TryToChangeScope(self, after: { () -> Void in
                
                self.JoinAsTeacher()
            })
        }
        else{
            
            JoinAsTeacher()
        }
    }
    
    func JoinAsTeacher(){
        
        if let code = self.codeTextField.text{
            
            var rsp : String
            
            do{
                rsp = try Resource.Connection.SendRequest(self._DsnsItem.AccessPoint, contract: "auth.guest", service: "Join.AsTeacher", body: "<Request><TeacherCode>\(code)</TeacherCode></Request>")
            }
            catch ConnectionError.connectError(let reason){
                ShowErrorAlert(self, title: "加入失敗", msg: reason)
                return
            }
            catch{
                ShowErrorAlert(self, title: "加入失敗", msg: "發生不明的錯誤,請回報給開發人員")
                return
            }
            
            let xml: AEXMLDocument?
            
            do {
                xml = try AEXMLDocument(xmlData: rsp.dataValue)
            } catch _ {
                xml = nil
            }
            
            if let id = xml?.root["Response"]["RefID"].stringValue where !id.isEmpty{
                
                let alert = UIAlertController(title: "加入成功", message: "", preferredStyle: UIAlertControllerStyle.Alert)
                
                alert.addAction(UIAlertAction(title: "確認", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                    
                    self.navigationController?.popViewControllerAnimated(true)
                }))
                
                self.presentViewController(alert, animated: true, completion: nil)
            }
            else{
                ShowErrorAlert(self, title: "加入失敗", msg: "發生不明的錯誤,請回報給開發人員")
            }
        }
        
    }
    
}

