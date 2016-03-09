//
//  LeftViewCtrl.swift
//  ischoolFramework
//
//  Created by Cloud on 2016/3/7.
//  Copyright © 2016年 ischool. All rights reserved.
//

import UIKit

class LeftViewCtrl : UIViewController,UITableViewDelegate,UITableViewDataSource{
    
    var Resource : Resources!
    
    var DsnsList : [DsnsItem]!
    
    var Children : [Student]!
    
    var currentDsns : DsnsItem?
    
    var currentChild : Student?
    
    var currentPassValue : PassValue?
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var icon: UIImageView!
    
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var account: UILabel!
    
    @IBOutlet weak var schoolBtn: UIButton!
    
    @IBOutlet weak var childBtn: UIButton!
    
    @IBAction func changeSchool(sender: AnyObject) {
        
        let menu = UIAlertController(title: "請選擇學校", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        menu.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
        
        for dsns in DsnsList{
            
            menu.addAction(UIAlertAction(title: dsns.Name, style: UIAlertActionStyle.Default, handler: { (act) -> Void in
                
                self.schoolBtn.setTitle(dsns.Name, forState: UIControlState.Normal)
                
                self.childBtn.setTitle("", forState: UIControlState.Normal)
                
                self.currentDsns = dsns
                
                self.currentChild = nil
                
                self.currentPassValue?.delegate?.DsnsChanged(dsns.AccessPoint)
                
                self.Children = GetMyChildren(self.Resource, dsns: dsns.AccessPoint)
                
                SlideView.ToggleSideMenu()
            }))
        }
        
        self.presentViewController(menu, animated: true, completion: nil)
        
    }
    
    @IBAction func changeChild(sender: AnyObject) {
        
        let menu = UIAlertController(title: "請選擇小孩", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        menu.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
        
        for child in Children{
            
            menu.addAction(UIAlertAction(title: child.Name, style: UIAlertActionStyle.Default, handler: { (act) -> Void in
                
                self.childBtn.setTitle(child.Name, forState: UIControlState.Normal)
                
                self.currentPassValue?.delegate?.StudentIdChanged(child.ID)
                
                self.currentChild = child
                
                SlideView.ToggleSideMenu()
                
            }))
        }
        
        self.presentViewController(menu, animated: true, completion: nil)
    }
    
    //var cons : ConnectionManager
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        Resource.Account.SetInfo((Resource.Connection.loginHelper.AccessToken))
        
        icon.image = Resource.Account.MyPhoto
        
        name.text = Resource.Account.Name
        
        account.text = Resource.Account.Account
        
        DsnsList = GetDsnsList(Resource.Connection.loginHelper.AccessToken)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        return Resource.Functions.GetPools()?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        let funcShell = Resource.Functions.GetPools()?[indexPath.row]
        
        var cell = tableView.dequeueReusableCellWithIdentifier("cell")
        
        if cell == nil{
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "cell")
        }
        
        cell?.imageView?.image = funcShell?.Icon
        
        cell?.textLabel?.text = funcShell?.Name
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        
        let funcShell = Resource.Functions.GetPools()?[indexPath.row]
        
        let passvalue = PassValue(dsns: currentDsns?.AccessPoint, id: currentChild?.ID, connectionManager: Resource.Connection)
        
        let vc = funcShell?.GetViewController()
        
        vc?.passValue = passvalue
        
        self.currentPassValue = passvalue
        
        SlideView.ChangeContentView(vc!)
    }

}
