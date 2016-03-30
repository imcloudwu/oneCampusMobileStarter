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
    
    //var Children : [Student]!
    
    var currentDsns : DsnsItem?
    
    var currentStudent : ChosedStudent?
    
    var currentIdenty : IdentityType?
    
    var currentFunctions : [ischoolProtocol]?
    
    var identyTypes = [IdentityType.Admin,IdentityType.CourseTeacher,IdentityType.ClassTeacher,IdentityType.Parent]
    
    var lastSelected : NSIndexPath?
    
    var currentAppContext : AppContext?
    
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
                
                self.currentAppContext?.Identy = type
                
                self.currentIdenty = type
                
                self.identyBtn.setTitle("\(type.rawValue)", forState: UIControlState.Normal)
                
                self.ResetDsns()
                
                Keychain.mainSave(Keychain.Key.CurrentIdenty.rawValue, data: type.rawValue.dataValue)
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
                    
                    self.currentAppContext?.Dsns = dsns.AccessPoint
                    
                    self.schoolBtn.setTitle(dsns.Name, forState: UIControlState.Normal)
                    
                    self.currentDsns = dsns
                    
                    self.currentFunctions = self.GetFunctionByIDs(self.GetFunctionIDsBySchool(dsns.AccessPoint))
                    
                    self.tableView.reloadData()
                    
                    self.ResetStudent()
                    
                }))
            }
        }
        
        if currentIdenty == IdentityType.ClassTeacher || currentIdenty == IdentityType.CourseTeacher{
            
            menu.addAction(UIAlertAction(title: "新 增 班 級", style: UIAlertActionStyle.Destructive, handler: { (act) -> Void in
                
                let nextView = frameworkStoryboard.instantiateViewControllerWithIdentifier("AsTeacherViewCtrl") as! AsTeacherViewCtrl
                
                nextView.Resource = self.Resource
                
                SlideView.ChangeContentView(nextView)
            }))
        }
        else if currentIdenty == IdentityType.Parent{
            
            menu.addAction(UIAlertAction(title: "加 入 小 孩", style: UIAlertActionStyle.Destructive, handler: { (act) -> Void in
                
                let nextView = frameworkStoryboard.instantiateViewControllerWithIdentifier("AddChildMainViewCtrl") as! AddChildMainViewCtrl
                
                nextView.Resource = self.Resource
                
                SlideView.ChangeContentView(nextView)
            }))
        }
        
        self.presentViewController(menu, animated: true, completion: nil)
        
    }
    
    @IBAction func changeChild(sender: AnyObject) {
        
        if currentIdenty == IdentityType.Admin || currentIdenty == IdentityType.ClassTeacher || currentIdenty == IdentityType.CourseTeacher{
            
            let classViewCtrl = frameworkStoryboard.instantiateViewControllerWithIdentifier("ClassViewCtrl") as! ClassViewCtrl
            
            let choseStudent = ChosedStudent()
            
            self.currentStudent = choseStudent
            
            classViewCtrl.appContext = GetAppContext()
            
            classViewCtrl.chosedStudent = choseStudent
            
            classViewCtrl.afterSelected = SelectedFunction
            
            classViewCtrl.Resource = self.Resource
            
            SlideView.ChangeContentView(classViewCtrl)
        }
        else if currentIdenty == IdentityType.Parent{
            
            let studentViewCtrl = frameworkStoryboard.instantiateViewControllerWithIdentifier("StudentViewCtrl") as! StudentViewCtrl
            
            let choseStudent = ChosedStudent()
            
            self.currentStudent = choseStudent
            
            studentViewCtrl.appContext = GetAppContext()
            
            studentViewCtrl.chosedStudent = choseStudent
            
            studentViewCtrl.afterSelected = SelectedFunction
            
            studentViewCtrl.Resource = self.Resource
            
            SlideView.ChangeContentView(studentViewCtrl)
        }
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
        
        if let lastIdenty = Keychain.load("currentIdenty")?.stringValue{
            
            switch(lastIdenty){
                
            case IdentityType.Admin.rawValue:
                self.currentIdenty = IdentityType.Admin
                
            case IdentityType.CourseTeacher.rawValue:
                self.currentIdenty = IdentityType.CourseTeacher
                
            case IdentityType.ClassTeacher.rawValue:
                self.currentIdenty = IdentityType.ClassTeacher
                
            default:
                self.currentIdenty = IdentityType.Parent
            }
            
            self.identyBtn.setTitle(self.currentIdenty?.rawValue, forState: UIControlState.Normal)
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        if let name = currentStudent?.Name{
            
            childBtn.setTitle(name, forState: UIControlState.Normal)
        }
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
            
            return count + 1
        }
        
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        var cell = tableView.dequeueReusableCellWithIdentifier("cell")
        
        if cell == nil{
            
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "cell")
            
            //cell?.selectionStyle = UITableViewCellSelectionStyle.None
        }
        
        if let count = self.currentFunctions?.count where indexPath.row == count{
            
            cell?.imageView?.image = UIImage(named: "Exit Filled-50.png", inBundle: frameworkBundle, compatibleWithTraitCollection: nil)?.GetResizeImage(30, height: 30)
            
            cell?.textLabel?.text = "登          出"
            
            return cell!
        }
        
        let funcShell = self.currentFunctions?[indexPath.row]
        
        cell?.imageView?.image = funcShell?.Icon?.GetResizeImage(30, height: 30)
        
        cell?.textLabel?.text = funcShell?.Name
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        
        if let count = self.currentFunctions?.count where indexPath.row == count {
            
            Logout()
        }
        else{
            
            lastSelected = indexPath
            
            SelectedFunction()
        }
        
    }
    
    func SelectedFunction(){
        
        if let index = lastSelected{
            
            let funcShell = self.currentFunctions?[index.row]
            
            let vc = funcShell?.GetViewController()
            
            vc?.appContext = GetAppContext()
            
            let navtitle = funcShell?.Name
            
            vc?.navtitle = navtitle
            
            SlideView.ChangeContentView(vc!)
        }
        else{
            
            SlideView.ToggleSideMenu()
        }
    }
    
    func GetFunctionIDsBySchool(dsns:String) -> [String]{
        
        if dsns == "dev.sh_d"{
            
            return ["tw.ischool.AbsenceModule","tw.ischool.DisciplineModule","tw.ischool.ExamScoreModule","tw.ischool.SemesterScoreModule"]
        }
        else{
            
            return ["tw.ischool.AbsenceModule"]
        }
    }
    
    func GetFunctionByIDs(ids:[String]) -> [ischoolProtocol]{
        
        //return Resource.Functions.GetFunctionsByIDs(ids)
        
        return Resource.Functions.GetAllFunctions()
    }
    
    func GetAppContext() -> AppContext{
        
        let appContext = AppContext(identy: self.currentIdenty, dsns: currentDsns?.AccessPoint, id: currentStudent?.Id, data: currentStudent?.Data?.Clone(),connectionManager: Resource.Connection)
        
        self.currentAppContext = appContext
        
        return appContext
    }
    
    func ResetDsns(){
        
        self.currentAppContext?.Dsns = nil
        
        self.currentDsns = nil
        
        self.schoolBtn.setTitle("請選擇學校", forState: UIControlState.Normal)
        
        self.ResetStudent()
    }
    
    func ResetStudent(){
        
        self.currentAppContext?.Id = nil
        
        self.currentStudent = nil
        
        self.childBtn.setTitle("請選擇學生", forState: UIControlState.Normal)
    }

}
