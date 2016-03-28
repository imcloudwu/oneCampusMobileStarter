//
//  ClassViewCtrl.swift
//  ischoolFramework
//
//  Created by Cloud on 2016/3/22.
//  Copyright © 2016年 ischool. All rights reserved.
//

import UIKit

class ClassViewCtrl: ischoolViewCtrl,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate{
    
    let adminContract = "1campus.mobile.dominator"
    
    let teacherContract = "1campus.mobile.teacher"
    
    var chosedStudent : ChosedStudent?
    
    var firstTime = true
    
    var afterSelected : (() -> ())?
    
    var Resource : Resources?
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var refreshControl : UIRefreshControl!
    
    var _ClassList = [ClassItem]()
    var _DisplayDatas = [ClassItem]()
    var _CurrentDatas = [ClassItem]()
    
    var DsnsResult = [String:Bool]()
    
    let redColor = UIColor(red: 244 / 255, green: 67 / 255, blue: 54 / 255, alpha: 1)
    let blueColor = UIColor(red: 33 / 255, green: 150 / 255, blue: 243 / 255, alpha: 1)
    
    override func viewWillAppear(animated: Bool) {
        
        if !firstTime{
            return
        }
        
        firstTime = false
        
        searchBar.delegate = self
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "")
        self.refreshControl.addTarget(self, action: "ReloadData", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
        
        tableView.delegate = self
        tableView.dataSource = self
        self.navigationItem.title = "班 級 列 表"
        self.navigationController?.interactivePopGestureRecognizer?.enabled = false
        
        GetData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func ReloadData(){
        
        self.refreshControl.endRefreshing()
        
        GetData()
    }
    
    func GetData(){
        
        if let identy = appContext?.Identy{
            
            switch(identy){
                
            case .Admin:
                GetAllClass()
                
            case .ClassTeacher:
                GetMyClassData()
                
            default:
                GetMyCourseData()
            }
        }
    }
    
    func SetData(data:[ClassItem]){
        
        self._ClassList = data
        self._CurrentDatas = data
        self._DisplayDatas = data
        
        self.tableView.reloadDataWithAnimated()
    }
    
    func GetAllClass(){
        
        var retVal = [ClassItem]()
        
        if let dsns = appContext?.Dsns{
            
            appContext?.SendRequest(adminContract, srevice: "main.GetAllClass", req: "", successCallback: { (response) -> () in
                
                var xml: AEXMLDocument?
                
                do {
                    xml = try AEXMLDocument(xmlData: response.dataValue)
                } catch _ {
                    xml = nil
                }
                
                if let classes = xml?.root["ClassList"]["Class"].all {
                    for cls in classes{
                        let ClassID = cls["ClassID"].stringValue
                        let ClassName = cls["ClassName"].stringValue
                        let GradeYear = Int(cls["GradeYear"].stringValue) ?? 0
                        let TeacherName = cls["TeacherName"].stringValue
                        let TeacherAccount = cls["TeacherAccount"].stringValue
                        
                        retVal.append(ClassItem(DSNS : dsns, ID: ClassID, ClassName: ClassName, AccessPoint: dsns, GradeYear: GradeYear, TeacherName: TeacherName, TeacherAccount : TeacherAccount))
                    }
                }
                
                if retVal.count > 0{
                    
                    let schoolName = GetSchoolName(dsns)
                    //GetAllTeacherAccount(schoolName, con: con)
                    
                    retVal.insert(ClassItem(DSNS : dsns, ID: "header", ClassName: schoolName, AccessPoint: "", GradeYear: 0, TeacherName: "", TeacherAccount : ""), atIndex: 0)
                }
                
                self.SetData(retVal)
                
                }, failureCallback: { (error) -> () in
                    
                    print(error)
                    
                    self.SetData(retVal)
            })
            
        }
    }
    
    func GetMyClassData(){
        
        var retVal = [ClassItem]()
        
        if let dsns = appContext?.Dsns{
            
            appContext?.SendRequest(teacherContract, srevice: "main.GetMyTutorClasses", req: "", successCallback: { (response) -> () in
                
                var xml: AEXMLDocument?
                
                do {
                    xml = try AEXMLDocument(xmlData: response.dataValue)
                } catch _ {
                    xml = nil
                }
                
                if let classes = xml?.root["ClassList"]["Class"].all {
                    for cls in classes{
                        let ClassID = cls["ClassID"].stringValue
                        let ClassName = cls["ClassName"].stringValue
                        let GradeYear = Int(cls["GradeYear"].stringValue) ?? 0
                        
                        retVal.append(ClassItem(DSNS: dsns, ID: ClassID, ClassName: ClassName, AccessPoint: dsns, GradeYear: GradeYear, TeacherName: "導師", TeacherAccount: ""))
                    }
                }
                
                self.SetData(retVal)
                
                }, failureCallback: { (error) -> () in
                    
                    print(error)
            })
            
        }
    }
    
    func GetMyCourseData(){
        
        var retVal = [ClassItem]()
        
        if let dsns = appContext?.Dsns{
            
            var schoolYear = ""
            var semester = ""
            
            appContext?.SendRequest(teacherContract, srevice: "main.GetCurrentSemester", req: "", successCallback: { (response) -> () in
                
                var xml: AEXMLDocument?
                do {
                    xml = try AEXMLDocument(xmlData: response.dataValue)
                } catch _ {
                    xml = nil
                }
                
                if let sy = xml?.root["Response"]["SchoolYear"].first?.stringValue{
                    schoolYear = sy
                }
                
                if let sm = xml?.root["Response"]["Semester"].first?.stringValue{
                    semester = sm
                }
                
                self.appContext?.SendRequest(self.teacherContract, srevice: "main.GetMyCourses", req: "<Request><All></All><SchoolYear>\(schoolYear)</SchoolYear><Semester>\(semester)</Semester></Request>", successCallback: { (response) -> () in
                    
                    do {
                        xml = try AEXMLDocument(xmlData: response.dataValue)
                    } catch _ {
                        xml = nil
                    }
                    
                    if let classes = xml?.root["ClassList"]["Class"].all {
                        
                        for cls in classes{
                            
                            let CourseID = cls["CourseID"].stringValue
                            let CourseName = cls["CourseName"].stringValue
                            let GradeYear = Int(cls["GradeYear"].stringValue) ?? 0
                            
                            retVal.append(ClassItem(DSNS: dsns, ID: CourseID, ClassName: CourseName, AccessPoint: dsns, GradeYear: GradeYear, TeacherName: "授課", TeacherAccount: ""))
                        }
                    }
                    
                    self.SetData(retVal)

                    }, failureCallback: { (error) -> () in
                        
                        print(error)
                        
                        self.SetData(retVal)
                })
                
                }, failureCallback: { (error) -> () in
                    
                    print(error)
                    
                    self.SetData(retVal)
            })
            
        }
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return _DisplayDatas.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        let data = _DisplayDatas[indexPath.row]
        
        if data.ID == "header"{
            var cell = tableView.dequeueReusableCellWithIdentifier("summaryItem")
            
            if cell == nil{
                cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "summaryItem")
                cell?.backgroundColor = UIColor(red: 238 / 255, green: 238 / 255, blue: 238 / 255, alpha: 1)
            }
            
            cell?.textLabel?.text = data.ClassName
            return cell!
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ClassCell") as! ClassCell
        cell.ClassName.text = data.ClassName
        cell.Major.text = data.TeacherName
        cell.classItem = data
        
        //字串擷取
        if (data.ClassName as NSString).length > 0{
            let subString = (data.ClassName as NSString).substringToIndex(1)
            cell.ClassIcon.text = subString
        }
        else{
            cell.ClassIcon.text = ""
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        
        let data = _DisplayDatas[indexPath.row]
        
        if data.ID != "header"{
            
            let nextView = self.storyboard?.instantiateViewControllerWithIdentifier("StudentViewCtrl") as! StudentViewCtrl
            
            nextView.appContext = self.appContext
            
            nextView.ClassData = data
            
            nextView.chosedStudent = self.chosedStudent
            
            nextView.afterSelected = self.afterSelected
            
            nextView.Resource = self.Resource
            
            self.navigationController?.pushViewController(nextView, animated: true)
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        if _DisplayDatas[indexPath.row].ID == "header"{
            return 30
        }
        
        return 60
    }
    
    //Mark : SearchBar
    func searchBarSearchButtonClicked(searchBar: UISearchBar){
        searchBar.resignFirstResponder()
        self.view.endEditing(true)
        
        Search(searchBar.text!)
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        Search(searchText)
    }
    
    func Search(searchText:String){
        
        if searchText == "" {
            self._DisplayDatas = self._CurrentDatas
        }
        else{
            
            let founds = self._CurrentDatas.filter({ cls in
                
                if let _ = cls.ClassName.lowercaseString.rangeOfString(searchText.lowercaseString){
                    return true
                }
                
                if let _ = cls.TeacherName.lowercaseString.rangeOfString(searchText.lowercaseString){
                    return true
                }
                
                return false
            })
            
            self._DisplayDatas = founds
        }
        
        self.tableView.reloadData()
        
    }
}
