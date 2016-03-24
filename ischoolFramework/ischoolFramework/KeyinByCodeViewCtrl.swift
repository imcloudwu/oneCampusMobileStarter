//
//  KeyinByCodeViewCtrl.swift
//  ischoolFramework
//
//  Created by Cloud on 2016/3/17.
//  Copyright © 2016年 ischool. All rights reserved.
//

import UIKit

class KeyinByCodeViewCtrl: UIViewController,UIAlertViewDelegate,UITextFieldDelegate,UIWebViewDelegate {
    
    @IBOutlet weak var selectSchoolBtn: UIButton!
    
    @IBOutlet weak var code: UITextField!
    @IBOutlet weak var relationship: UITextField!
    
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
        
        code.delegate = self
        relationship.delegate = self
        
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
        
        if code.text!.isEmpty{
            ShowErrorAlert(self, title: "家長代碼必須填寫", msg: "")
            return
        }
        
        if relationship.text!.isEmpty{
            ShowErrorAlert(self, title: "親子關係必須填寫", msg: "")
            return
        }
        
        AddApplicationRef(serverName)
    }
    
    func AddApplicationRef(server:String){
        
        self._DsnsItem = DsnsItem(name: server, accessPoint: server)
        
        if !DsnsManager.Singleton.DsnsList.contains(self._DsnsItem){
            
            let _ = try? Resource.Connection.SendRequest("https://auth.ischool.com.tw:8443/dsa/greening", contract: "user", service: "AddApplicationRef", body: "<Request><Applications><Application><AccessPoint>\(server)</AccessPoint><Type>dynpkg</Type></Application></Applications></Request>")
            
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
        
        if let code = self.code.text, let relationship = self.relationship.text{
            
            let rsp = try? Resource.Connection.SendRequest(self._DsnsItem.AccessPoint, contract: "auth.guest", service: "Join.AsParent", body: "<Request><ParentCode>\(code)</ParentCode><Relationship>\(relationship)</Relationship></Request>")
            
            if rsp == nil{
                ShowErrorAlert(self, title: "加入失敗", msg: "發生不明的錯誤,請回報給開發人員")
                return
            }
            
            let xml: AEXMLDocument?
            
            do {
                xml = try AEXMLDocument(xmlData: rsp!.dataValue)
            } catch _ {
                xml = nil
            }
            
            if let msg = xml?.root["Success"].stringValue where msg.isEmpty{
                
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
