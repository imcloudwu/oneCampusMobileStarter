//
//  StudentViewCtrl.swift
//  ischoolFramework
//
//  Created by Cloud on 2016/3/22.
//  Copyright © 2016年 ischool. All rights reserved.
//

import UIKit

class StudentViewCtrl: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    let adminContract = "1campus.mobile.dominator"
    
    let teacherContract = "1campus.mobile.teacher"
    
    let parentContract = "1campus.mobile.parent"
    
    var appContext : AppContext?
    
    var chosedStudent : ChosedStudent?
    
    var afterSelected : (() -> ())?
    
    var Resource : Resources?
    
    @IBOutlet weak var btnHeight: NSLayoutConstraint!
    
    @IBOutlet weak var tableView: UITableView!
    
    var _studentData = [Student]()
    var _displayData = [Student]()
    var ClassData : ClassItem?
    
    override func viewDidLoad() {
        
        self.navigationItem.title = "請選擇學生"
        
        tableView.dataSource = self
        tableView.delegate = self
        
        btnHeight.constant = 0
        
        if let identy = appContext?.Identy{
            
            switch(identy){
                
            case .Admin:
                GetClassStudentDataByAdmin()
                
            case .ClassTeacher:
                GetClassStudentDataByClassTeacher()
                
            case .CourseTeacher:
                GetCourseStudentDataByCourseTeacher()
                
            default:
                
                btnHeight.constant = 44.0
                
                let img = UIImage(named: "Menu-24.png", inBundle: frameworkBundle, compatibleWithTraitCollection: nil)
                
                self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: img, style: UIBarButtonItemStyle.Plain, target: self, action: "ToggleSideMenu")
                
                GetMyChildren()
                
            }
        }

    }
    
    func ToggleSideMenu(){
        
        SlideView.ToggleSideMenu()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func SetData(data:[Student]){
        
        self._studentData = data
        self._displayData = data
        
        self.tableView.reloadDataWithAnimated()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return _displayData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCellWithIdentifier("studentCell") as! StudentCell
        cell.Photo.image = _displayData[indexPath.row].Photo
        cell.Label1.text = "\(_displayData[indexPath.row].Name)"
        cell.Label2.text = _displayData[indexPath.row].SeatNo == "" ? "" : "座號: \(_displayData[indexPath.row].SeatNo) "
        
        cell.student = _displayData[indexPath.row]
        
        return  cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        
        let student = self._displayData[indexPath.row]
        
        chosedStudent?.Name = student.Name
        
        chosedStudent?.Id = student.ID
        
        chosedStudent?.Data = student
        
        Toaster.ToastMessage(self.view, msg: "已選擇了 \(student.Name)", time: 1) { () -> () in
            
            self.afterSelected?()
        }
    }
    
    func GetClassStudentDataByAdmin(){
        
        var retVal = [Student]()
        
        if let dsns = appContext?.Dsns,let id = ClassData?.ID{
            
            appContext?.SendRequest(adminContract, srevice: "main.GetClassStudents", req: "<Request><All></All><ClassID>\(id)</ClassID></Request>", successCallback: { (response) -> () in
                
                var xml: AEXMLDocument?
                
                do {
                    xml = try AEXMLDocument(xmlData: response.dataValue)
                } catch _ {
                    xml = nil
                }
                
                if let students = xml?.root["Response"]["Student"].all {
                    for stu in students{
                        //println(stu.xmlString)
                        let studentID = stu["StudentID"].stringValue
                        let className = stu["ClassName"].stringValue
                        let studentName = stu["StudentName"].stringValue
                        let seatNo = stu["SeatNo"].stringValue
                        let studentNumber = stu["StudentNumber"].stringValue
                        let gender = stu["Gender"].stringValue
                        let mailingAddress = stu["MailingAddress"].xmlString
                        let permanentAddress = stu["PermanentAddress"].xmlString
                        let contactPhone = stu["ContactPhone"].stringValue
                        let permanentPhone = stu["PermanentPhone"].stringValue
                        let custodianName = stu["CustodianName"].stringValue
                        let fatherName = stu["FatherName"].stringValue
                        let motherName = stu["MotherName"].stringValue
                        let freshmanPhoto = GetImageFromBase64String(stu["FreshmanPhoto"].stringValue, defaultImg: UIImage(named: "User-100.png"))
                        
                        let stuItem = Student(DSNS: dsns,ID: studentID, ClassID: id, ClassName: className, Name: studentName, SeatNo: seatNo, StudentNumber: studentNumber, Gender: gender, MailingAddress: mailingAddress, PermanentAddress: permanentAddress, ContactPhone: contactPhone, PermanentPhone: permanentPhone, CustodianName: custodianName, FatherName: fatherName, MotherName: motherName, Photo: freshmanPhoto)
                        
                        retVal.append(stuItem)
                    }
                }
                
                self.SetData(retVal)
                
                }, failureCallback: { (error) -> () in
                    
                    print(error)
            })
        }
    }
    
    func GetClassStudentDataByClassTeacher(){
        
        var retVal = [Student]()
        
        if let dsns = appContext?.Dsns,let id = ClassData?.ID{
            
            appContext?.SendRequest(teacherContract, srevice: "main.GetClassStudents", req: "<Request><All></All><ClassID>\(id)</ClassID></Request>", successCallback: { (response) -> () in
                
                var xml: AEXMLDocument?
                
                do {
                    xml = try AEXMLDocument(xmlData: response.dataValue)
                } catch _ {
                    xml = nil
                }
                
                if let students = xml?.root["Response"]["Student"].all {
                    for stu in students{
                        //println(stu.xmlString)
                        let studentID = stu["StudentID"].stringValue
                        let className = stu["ClassName"].stringValue
                        let studentName = stu["StudentName"].stringValue
                        let seatNo = stu["SeatNo"].stringValue
                        let studentNumber = stu["StudentNumber"].stringValue
                        let gender = stu["Gender"].stringValue
                        let mailingAddress = stu["MailingAddress"].xmlString
                        let permanentAddress = stu["PermanentAddress"].xmlString
                        let contactPhone = stu["ContactPhone"].stringValue
                        let permanentPhone = stu["PermanentPhone"].stringValue
                        let custodianName = stu["CustodianName"].stringValue
                        let fatherName = stu["FatherName"].stringValue
                        let motherName = stu["MotherName"].stringValue
                        let freshmanPhoto = GetImageFromBase64String(stu["FreshmanPhoto"].stringValue, defaultImg: UIImage(named: "User-100.png"))
                        
                        let stuItem = Student(DSNS: dsns,ID: studentID, ClassID: id, ClassName: className, Name: studentName, SeatNo: seatNo, StudentNumber: studentNumber, Gender: gender, MailingAddress: mailingAddress, PermanentAddress: permanentAddress, ContactPhone: contactPhone, PermanentPhone: permanentPhone, CustodianName: custodianName, FatherName: fatherName, MotherName: motherName, Photo: freshmanPhoto)
                        
                        retVal.append(stuItem)
                    }
                }
                
                self.SetData(retVal)
                
                }, failureCallback: { (error) -> () in
                    
                    print(error)
            })
        }
    }
    
    func GetCourseStudentDataByCourseTeacher(){
        
        var retVal = [Student]()
        
        if let dsns = appContext?.Dsns,let id = ClassData?.ID{
            
            appContext?.SendRequest(teacherContract, srevice: "main.GetCourseStudent", req: "<Request><All></All><CourseID>\(id)</CourseID></Request>", successCallback: { (response) -> () in
                
                var xml: AEXMLDocument?
                
                do {
                    xml = try AEXMLDocument(xmlData: response.dataValue)
                } catch _ {
                    xml = nil
                }
                
                if let students = xml?.root["Response"]["Student"].all {
                    for stu in students{
                        //println(stu.xmlString)
                        let studentID = stu["StudentID"].stringValue
                        let className = stu["ClassName"].stringValue
                        let studentName = stu["StudentName"].stringValue
                        let seatNo = stu["SeatNo"].stringValue
                        let studentNumber = stu["StudentNumber"].stringValue
                        let gender = stu["Gender"].stringValue
                        let freshmanPhoto = GetImageFromBase64String(stu["FreshmanPhoto"].stringValue, defaultImg: UIImage(named: "User-100.png"))
                        
                        let stuItem = Student(DSNS: dsns,ID: studentID, ClassID : id, ClassName: className, Name: studentName, SeatNo: seatNo, StudentNumber: studentNumber, Gender: gender, MailingAddress: "", PermanentAddress: "", ContactPhone: "", PermanentPhone: "", CustodianName: "", FatherName: "", MotherName: "", Photo: freshmanPhoto)
                        
                        retVal.append(stuItem)
                    }
                }
                
                self.SetData(retVal)
                
                }, failureCallback: { (error) -> () in
                    
                    print(error)
            })
            
        }
        
    }
    
    func GetMyChildren(){
        
        var retVal = [Student]()
        
        if let dsns = appContext?.Dsns{
            
            appContext?.SendRequest(parentContract, srevice: "main.GetMyChildren", req: "", successCallback: { (response) -> () in
                
                let xml: AEXMLDocument?
                do {
                    xml = try AEXMLDocument(xmlData: response.dataValue)
                } catch _ {
                    xml = nil
                }
                
                if let students = xml?.root["Student"].all {
                    for stu in students{
                        //println(stu.xmlString)
                        let studentID = stu["StudentId"].stringValue
                        let className = stu["ClassName"].stringValue
                        let studentName = stu["StudentName"].stringValue
                        let seatNo = stu["SeatNo"].stringValue
                        let studentNumber = stu["StudentNumber"].stringValue
                        let gender = stu["Gender"].stringValue
                        let mailingAddress = stu["MailingAddress"].xmlString
                        let permanentAddress = stu["PermanentAddress"].xmlString
                        let contactPhone = stu["ContactPhone"].stringValue
                        let permanentPhone = stu["PermanentPhone"].stringValue
                        let custodianName = stu["CustodianName"].stringValue
                        let fatherName = stu["FatherName"].stringValue
                        let motherName = stu["MotherName"].stringValue
                        let freshmanPhoto = GetImageFromBase64String(stu["StudentPhoto"].stringValue, defaultImg: UIImage(named: "User-100.png"))
                        
                        let stuItem = Student(DSNS: dsns,ID: studentID, ClassID: "", ClassName: className, Name: studentName, SeatNo: seatNo, StudentNumber: studentNumber, Gender: gender, MailingAddress: mailingAddress, PermanentAddress: permanentAddress, ContactPhone: contactPhone, PermanentPhone: permanentPhone, CustodianName: custodianName, FatherName: fatherName, MotherName: motherName, Photo: freshmanPhoto)
                        
                        retVal.append(stuItem)
                    }
                }
                
                retVal = retVal.sort({ Int($0.SeatNo) < Int($1.SeatNo) })
                
                self.SetData(retVal)
                
                }, failureCallback: { (error) -> () in
                    
                    print(error)
            })
        }
        
    }
    
    @IBAction func AddChildBtnClick(sender: AnyObject) {
        
        let addView = frameworkStoryboard.instantiateViewControllerWithIdentifier("AddChildMainViewCtrl") as! AddChildMainViewCtrl
        
        addView.Resource = self.Resource
        
        SlideView.ChangeContentView(addView)
    }
}