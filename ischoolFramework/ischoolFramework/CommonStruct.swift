//
//  CommonStruct.swift
//  oneCampusMobileStarter
//
//  Created by Cloud on 2016/3/2.
//  Copyright © 2016年 ischool. All rights reserved.
//

//import UIKit

struct ClassItem{
    var DSNS : String
    var ID : String
    var ClassName : String
    var AccessPoint : String
    var GradeYear : Int
    var TeacherName : String
    var TeacherAccount : String
}

class ClassCell : UITableViewCell{
    
    @IBOutlet weak var ClassIcon: UILabel!
    @IBOutlet weak var ClassName: UILabel!
    @IBOutlet weak var Major: UILabel!
    
    var classItem : ClassItem!
    
    override func awakeFromNib() {
        //        ClassIcon.layer.cornerRadius = 5
        //        ClassIcon.layer.masksToBounds = true
    }
}

class StudentCell : UITableViewCell{
    
    @IBOutlet weak var Photo: UIImageView!
    @IBOutlet weak var Label1: UILabel!
    @IBOutlet weak var Label2: UILabel!
    
    var student : Student!
    
    override func awakeFromNib() {
        Photo.layer.cornerRadius = Photo.frame.size.width / 2
        Photo.layer.masksToBounds = true
    }
}

class ChosedStudent {
    var Name : String?
    var Id : String?
    var Data : Student?
}

public class Student : Equatable{
    public var DSNS : String!
    public var ID : String!
    public var ClassID : String!
    public var ClassName : String!
    public var Name : String!
    public var SeatNo : String!
    public var StudentNumber : String!
    public var Gender : String!
    public var MailingAddress : String!
    public var PermanentAddress : String!
    public var ContactPhone : String!
    public var PermanentPhone : String!
    public var CustodianName : String!
    public var FatherName : String!
    public var MotherName : String!
    public var Photo : UIImage!
    
    public init(DSNS: String,ID: String, ClassID: String, ClassName: String, Name: String, SeatNo: String, StudentNumber: String, Gender: String, MailingAddress: String, PermanentAddress: String, ContactPhone: String, PermanentPhone: String, CustodianName: String, FatherName: String, MotherName: String, Photo: UIImage?){
        
        self.DSNS = DSNS
        self.ID = ID
        self.ClassID = ClassID
        self.ClassName = ClassName
        self.Name = Name
        self.SeatNo = SeatNo
        self.StudentNumber = StudentNumber
        self.Gender = Gender
        self.MailingAddress = MailingAddress
        self.PermanentAddress = PermanentAddress
        self.ContactPhone = ContactPhone
        self.PermanentPhone = PermanentPhone
        self.CustodianName = CustodianName
        self.FatherName = FatherName
        self.MotherName = MotherName
        self.Photo = Photo
    }
    
    public func Clone() -> Student{
        
        return Student(DSNS: DSNS, ID: ID, ClassID: ClassID, ClassName: ClassName, Name: Name, SeatNo: SeatNo, StudentNumber: StudentNumber, Gender: Gender, MailingAddress: MailingAddress, PermanentAddress: PermanentAddress, ContactPhone: ContactPhone, PermanentPhone: PermanentPhone, CustodianName: CustodianName, FatherName: FatherName, MotherName: MotherName, Photo: Photo)
    }
}

public func ==(lhs: Student, rhs: Student) -> Bool {
    return lhs.DSNS == rhs.DSNS && lhs.ID == rhs.ID
}


public struct SemesterItem : Equatable,Comparable{
    
    public var SchoolYear : String
    public var Semester : String
    
    public init(SchoolYear:String,Semester:String){
        
        self.SchoolYear = SchoolYear
        self.Semester = Semester
    }
    
    public var Description: String {
        get {
            return "第\(SchoolYear)學年度\(Semester)學期"
        }
    }
    
    var CompareValue : Int{
        if let sy = Int(SchoolYear) , let sm = Int(Semester){
            return sy * 10 + sm
        }
        else{
            return 0
        }
    }
}

public func ==(lhs: SemesterItem, rhs: SemesterItem) -> Bool {
    return lhs.SchoolYear == rhs.SchoolYear && lhs.Semester == rhs.Semester
}

public func <(lhs: SemesterItem, rhs: SemesterItem) -> Bool{
    return lhs.CompareValue < rhs.CompareValue
}

