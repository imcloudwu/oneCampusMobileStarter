//
//  LeftViewCtrl.swift
//  ischoolFramework
//
//  Created by Cloud on 2016/3/7.
//  Copyright © 2016年 ischool. All rights reserved.
//

import UIKit

class LeftViewCtrl : UIViewController,UITableViewDelegate,UITableViewDataSource{
    
    var firstTime = true
    
    var Resource : Resources!
    
    var Children : [Student]!
    
    var currentDsns : DsnsItem?
    
    var currentChild : Student?
    
    var currentIdenty : IdentityType?
    
    var currentAppContext : AppContext?
    
    var currentFunctions : [ischoolProtocol]?
    
    var identyTypes = [IdentityType.Admin,IdentityType.Teacher,IdentityType.Parent]
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var icon: UIImageView!
    
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var account: UILabel!
    
    @IBOutlet weak var identyBtn: UIButton!
    
    @IBOutlet weak var schoolBtn: UIButton!
    
    @IBOutlet weak var childBtn: UIButton!
    
    func Logout(){
        
        let alert = UIAlertController(title: "確認要登出嗎？", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Destructive, handler: { (action) -> Void in
            
            self.Resource.Connection.loginHelper.CleanAccessTokenAndRefreshToken()
            
            self.dismissViewControllerAnimated(true, completion: nil)
            
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func changeIdenty(sender: AnyObject) {
        
        let menu = UIAlertController(title: "請選擇身份", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        menu.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
        
        for type in self.identyTypes{
            
            menu.addAction(UIAlertAction(title: "\(type.rawValue)", style: UIAlertActionStyle.Default, handler: { (act) -> Void in
                
                self.currentIdenty = type
                
                self.identyBtn.setTitle("\(type.rawValue)", forState: UIControlState.Normal)
            }))
        }
        
        self.presentViewController(menu, animated: true, completion: nil)
    }
    
    @IBAction func changeSchool(sender: AnyObject) {
        
        let menu = UIAlertController(title: "請選擇學校", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        menu.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
        
        if DsnsManager.Singleton.DsnsList.count > 0{
            
            for dsns in DsnsManager.Singleton.DsnsList{
                
                menu.addAction(UIAlertAction(title: dsns.Name, style: UIAlertActionStyle.Default, handler: { (act) -> Void in
                    
                    self.schoolBtn.setTitle(dsns.Name, forState: UIControlState.Normal)
                    
                    self.childBtn.setTitle("請選擇學生", forState: UIControlState.Normal)
                    
                    self.currentDsns = dsns
                    
                    self.currentChild = nil
                    
                    self.currentAppContext = nil
                    
                    //self.currentAppContext?.delegate?.DsnsChanged(dsns.AccessPoint)
                    
                    self.Children = GetMyChildren(self.Resource, dsns: dsns.AccessPoint)
                    
                    self.currentFunctions = self.GetFunctionByIDs(self.GetFunctionIDsBySchool(dsns.AccessPoint))
                    
                    self.tableView.reloadData()
                    
                    let rightView = frameworkStoryboard.instantiateViewControllerWithIdentifier("RightViewCtrl")
                    
                    SlideView.ChangeContentView(rightView)
                }))
            }
        }
        else{
            
            AddChildOption(menu)
        }
        
        self.presentViewController(menu, animated: true, completion: nil)
        
    }
    
    @IBAction func changeChild(sender: AnyObject) {
        
        let menu = UIAlertController(title: "請選擇學生", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        menu.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
        
        if let children = Children{
            
            for child in children{
                
                menu.addAction(UIAlertAction(title: child.Name, style: UIAlertActionStyle.Default, handler: { (act) -> Void in
                    
                    self.childBtn.setTitle(child.Name, forState: UIControlState.Normal)
                    
                    self.currentAppContext?.delegate?.StudentIdChanged(child.ID)
                    
                    self.currentChild = child
                    
                    SlideView.ToggleSideMenu()
                    
                }))
            }
        }
        
        AddChildOption(menu)
        
        self.presentViewController(menu, animated: true, completion: nil)
    }
    
    func AddChildOption(menu:UIAlertController){
    
        //加入小孩
        menu.addAction(UIAlertAction(title: "加 入 小 孩", style: UIAlertActionStyle.Destructive, handler: { (act) -> Void in
            
            self.schoolBtn.setTitle("請選擇學校", forState: UIControlState.Normal)
            
            self.childBtn.setTitle("請選擇小孩", forState: UIControlState.Normal)
            
            self.currentDsns = nil
            
            self.currentChild = nil
            
            self.Children = nil
            
            let addView = frameworkStoryboard.instantiateViewControllerWithIdentifier("AddChildMainViewCtrl") as! AddChildMainViewCtrl
            
            addView.Resource = self.Resource
            
            SlideView.ChangeContentView(addView)
        }))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        Resource.Connection.loginHelper.accountInfo.SetInfo((Resource.Connection.loginHelper.AccessToken))
        
        icon.layer.cornerRadius = icon.frame.width / 2
        
        icon.layer.masksToBounds = true
        
        icon.image = Resource.Connection.loginHelper.accountInfo.Photo
        
        name.text = Resource.Connection.loginHelper.accountInfo.Name
        
        account.text = Resource.Connection.loginHelper.accountInfo.Account
        
        DsnsManager.Singleton.DsnsList = GetDsnsList(Resource.Connection.loginHelper.AccessToken)

        self.currentFunctions = [ischoolProtocol]()
    }
    
    override func viewDidAppear(animated: Bool) {
        
        guard firstTime else{
            return
        }
        
        firstTime = false
        
        if self.currentFunctions?.count > 0{
            
            let indexPath = NSIndexPath(forRow: 0, inSection: 0)
            
            tableView(tableView, didSelectRowAtIndexPath: indexPath)
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        if let count = self.currentFunctions?.count{
            
            return count + 2
        }
        
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        var cell = tableView.dequeueReusableCellWithIdentifier("cell")
        
        if cell == nil{
            
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "cell")
            
            //cell?.selectionStyle = UITableViewCellSelectionStyle.None
        }
        
        if let count = self.currentFunctions?.count where indexPath.row == count + 1{
            
            cell?.imageView?.image = UIImage(named: "Exit Filled-50.png", inBundle: frameworkBundle, compatibleWithTraitCollection: nil)?.GetResizeImage(30, height: 30)
            
            cell?.textLabel?.text = "登          出"
            
            return cell!
        }
        else if let count = self.currentFunctions?.count where indexPath.row == count{
            
            cell?.imageView?.image = UIImage(named: "Change User Filled-50.png", inBundle: frameworkBundle, compatibleWithTraitCollection: nil)?.GetResizeImage(30, height: 30)
            
            cell?.textLabel?.text = "身 份 切 換"
            
            return cell!
        }
        
        let funcShell = self.currentFunctions?[indexPath.row]
        
        cell?.imageView?.image = funcShell?.Icon?.GetResizeImage(30, height: 30)
        
        cell?.textLabel?.text = funcShell?.Name
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        
        if let count = self.currentFunctions?.count where indexPath.row == count + 1{
            
            Logout()
        }
        else if let count = self.currentFunctions?.count where indexPath.row == count{
            
            ChangeIdenty()
        }
        else{
            
            let funcShell = self.currentFunctions?[indexPath.row]
            
            let appContext = AppContext(identy: self.currentIdenty, dsns: currentDsns?.AccessPoint, id: currentChild?.ID, connectionManager: Resource.Connection)
            
            let vc = funcShell?.GetViewController()
            
            vc?.appContext = appContext
            
            let navtitle = funcShell?.Name
            
            vc?.navtitle = navtitle
            
            self.currentAppContext = appContext
            
            SlideView.ChangeContentView(vc!)
        }
        
    }
    
    func ChangeIdenty(){
        
//        self.currentAppContext = nil
//        
//        let view = frameworkStoryboard.instantiateViewControllerWithIdentifier("IdentyViewCtrl") as! IdentyViewCtrl
//        
//        view.ParentIdentity = self.currentIdenty
//        
//        SlideView.ChangeContentView(view)
    }
    
    func GetFunctionIDsBySchool(dsns:String) -> [String]{
        
        if dsns == "dev.sh_d"{
            
            return ["tw.ischool.AbsenceModule","tw.ischool.DisciplineModule","tw.ischool.ExamScoreModule","tw.ischool.SemesterScoreModule"]
        }
        else{
            
            return ["tw.ischool.AbsenceModule"]
        }
        
        //return [String]()
    }
    
    func GetFunctionByIDs(ids:[String]) -> [ischoolProtocol]{
        
        return Resource.Functions.GetFunctionsByIDs(ids)
    }

}
