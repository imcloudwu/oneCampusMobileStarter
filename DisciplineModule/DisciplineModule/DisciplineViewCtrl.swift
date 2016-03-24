//
//  DisciplineViewCtrl.swift
//  DisciplineModule
//
//  Created by Cloud on 2016/3/14.
//  Copyright © 2016年 ischool. All rights reserved.
//

import UIKit
import ischoolFramework

class DisciplineViewCtrl : ischoolViewCtrl,UITableViewDataSource,UITableViewDelegate{
    
    var _data : [DisciplineItem]!
    var _displayData : [DisciplineItem]!
    var _displayDataBase : [DisciplineItem]!
    var _Semesters : [SemesterItem]!
    var _CurrentSemester : SemesterItem!
    var _SegmentItems : [String]!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var segment: UISegmentedControl!
    
    @IBAction func SegmentSelect(sender: AnyObject) {
        
        let type = _SegmentItems[segment.selectedSegmentIndex]
        
        self._displayData = type == "全部" ? self._displayDataBase : self._displayDataBase.filter({ data in
            
            switch type{
            case "大功":
                return data.MA > 0
            case "小功":
                return data.MB > 0
            case "嘉獎":
                return data.MC > 0
            case "大過":
                return data.DA > 0
            case "小過":
                return data.DB > 0
            case "警告":
                return data.DC > 0
            default:
                return false
            }
        })
        
        self.tableView.reloadDataWithAnimated()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        _data = [DisciplineItem]()
        _displayData = [DisciplineItem]()
        _displayDataBase = [DisciplineItem]()
        _Semesters = [SemesterItem]()
        _CurrentSemester = nil
        _SegmentItems = [String]()
        
        segment.removeAllSegments()
        segment.translatesAutoresizingMaskIntoConstraints = true
        
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.reloadData()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Search, target: self, action: "ChangeSemester")
        
        if let identy = appContext?.Identy {
            
            switch(identy){
                
            case .Admin:
                GetDisciplineData(adminContract,service: admin_service)
                
            case .ClassTeacher:
                GetDisciplineData(teacherContract,service: teacher_service)
                
            case .Parent:
                GetDisciplineData(parentContract,service: parent_service)
                
            default:
                print("identy not match")
            }
        }
    }
    
    func ChangeSemester(){
        let actionSheet = UIAlertController(title: "請選擇學年度學期", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
        actionSheet.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
        
        for semester in _Semesters{
            actionSheet.addAction(UIAlertAction(title: semester.Description, style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                self.SetDataToTableView(semester)
            }))
        }
        
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    func SetDataToTableView(semester:SemesterItem){
        
        self._CurrentSemester = semester
        
        var newData = [DisciplineItem]()
        
        var ma = 0
        var mb = 0
        var mc = 0
        var da = 0
        var db = 0
        var dc = 0
        
        for data in _data{
            if data.SchoolYear == semester.SchoolYear && data.Semester == semester.Semester{
                
                ma += data.MA
                mb += data.MB
                mc += data.MC
                
                if !data.IsClear{
                    da += data.DA
                    db += data.DB
                    dc += data.DC
                }
                
                newData.append(data)
            }
        }
        
        newData = newData.sort{$0.Date > $1.Date}
        
        segment.removeAllSegments()
        segment.insertSegmentWithTitle("警告(\(dc))", atIndex: 0, animated: false)
        segment.insertSegmentWithTitle("小過(\(db))", atIndex: 0, animated: false)
        segment.insertSegmentWithTitle("大過(\(da))", atIndex: 0, animated: false)
        segment.insertSegmentWithTitle("嘉獎(\(mc))", atIndex: 0, animated: false)
        segment.insertSegmentWithTitle("小功(\(mb))", atIndex: 0, animated: false)
        segment.insertSegmentWithTitle("大功(\(ma))", atIndex: 0, animated: false)
        segment.insertSegmentWithTitle("全部(\(dc + db + da + mc + mb + ma))", atIndex: 0, animated: true)
        
        _SegmentItems.removeAll(keepCapacity: false)
        _SegmentItems.insert("警告", atIndex: 0)
        _SegmentItems.insert("小過", atIndex: 0)
        _SegmentItems.insert("大過", atIndex: 0)
        _SegmentItems.insert("嘉獎", atIndex: 0)
        _SegmentItems.insert("小功", atIndex: 0)
        _SegmentItems.insert("大功", atIndex: 0)
        _SegmentItems.insert("全部", atIndex: 0)
        
        SetSegmentWidth()
        
        _displayDataBase = newData
        
        if _SegmentItems.count > 0{
            segment.selectedSegmentIndex = 0
            SegmentSelect(self)
        }
    }
    
    func GetDisciplineData(contract:String,service:String){
        
        var retVal = [DisciplineItem]()
        
        if let id = appContext?.Id where !id.isEmpty{
            
            appContext?.SendRequest(contract, srevice: service, req: "<Request><RefStudentId>\(id)</RefStudentId></Request>", successCallback: { (response) -> () in
                
                let xml = try? AEXMLDocument(xmlData: response.dataValue)
                
                if let disciplines = xml?.root["Response"]["Discipline"].all {
                    
                    for discipline in disciplines{
                        
                        let occurDate = discipline.attributes["OccurDate"]
                        let schoolYear = discipline.attributes["SchoolYear"]
                        let semester = discipline.attributes["Semester"]
                        let meritFlag = discipline.attributes["MeritFlag"] == "1" ? DisciplineType.Merit : DisciplineType.Demerit
                        let reason = discipline["Reason"].stringValue
                        
                        var ma = 0
                        var mb = 0
                        var mc = 0
                        var da = 0
                        var db = 0
                        var dc = 0
                        var isClear = false
                        
                        if meritFlag == DisciplineType.Merit{
                            ma = (discipline["Merit"].attributes["A"]?.intValue)!
                            mb = (discipline["Merit"].attributes["B"]?.intValue)!
                            mc = (discipline["Merit"].attributes["C"]?.intValue)!
                        }
                        else{
                            da = (discipline["Demerit"].attributes["A"]?.intValue)!
                            db = (discipline["Demerit"].attributes["B"]?.intValue)!
                            dc = (discipline["Demerit"].attributes["C"]?.intValue)!
                            isClear = discipline["Demerit"].attributes["Cleared"] == "是"
                        }
                        
                        let item = DisciplineItem(Type: meritFlag, Date: occurDate!, SchoolYear: schoolYear!, Semester: semester!, Reason: reason, IsClear: isClear, MA: ma, MB: mb, MC: mc, DA: da, DB: db, DC: dc)
                        
                        retVal.append(item)
                    }
                }
                
                self._data = retVal
                
                self.GetSemesters()
                
                if self._Semesters.count > 0{
                    self.SetDataToTableView(self._Semesters[0])
                }
                
                }, failureCallback: { (error) -> () in
                    
                    print(error)
            })
        }
    }
    
    //整理出資料的學年度學期
    func GetSemesters(){
        
        var retVal = [SemesterItem]()
        
        for data in _data{
            
            let semester = SemesterItem(SchoolYear: data.SchoolYear, Semester: data.Semester)
            
            if !retVal.contains(semester){
                
                retVal.append(semester)
            }
        }
        
        self._Semesters = retVal.sort({$0 > $1})
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return _displayData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        let data = _displayData[indexPath.row]
        
        if data.Type == DisciplineType.Merit{
            
            let cell = tableView.dequeueReusableCellWithIdentifier("MeritItemCell") as! MeritItemCell
            
            cell.Date.text = data.Date
            
            cell.Reason.text = data.Reason
            
            cell.Status1.text = "\(data.MA)"
            
            cell.Status2.text = "\(data.MB)"
            
            cell.Status3.text = "\(data.MC)"
            
            return cell
        }
        else{
            
            let cell = tableView.dequeueReusableCellWithIdentifier("DemeritItemCell") as! DemeritItemCell
            
            cell.Date.text = data.Date
            
            cell.Reason.text = data.Reason
            
            cell.Status1.text = "\(data.DA)"
            
            cell.Status2.text = "\(data.DB)"
            
            cell.Status3.text = "\(data.DC)"
            
            if data.IsClear{
                cell.Reason.text = "(已註銷) " + data.Reason
            }
            
            return cell
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return _CurrentSemester?.Description
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        
        SetSegmentWidth()
    }
    
    func SetSegmentWidth(){
        
        var besSize = segment.sizeThatFits(CGSize.zero)
        
        let screenwidth = scrollView.frame.width
        
        if besSize.width < screenwidth {
            
            besSize.width = screenwidth
        }
        
        segment.frame.size.width = besSize.width
        
        scrollView.contentSize = CGSizeMake(besSize.width , 0)
        
        scrollView.contentOffset = CGPointMake(0 - self.scrollView.contentInset.left, 0)
    }
}

struct DisciplineItem {
    var Type:DisciplineType
    var Date:String
    var SchoolYear:String
    var Semester:String
    var Reason:String
    var IsClear:Bool
    var MA:Int
    var MB:Int
    var MC:Int
    var DA:Int
    var DB:Int
    var DC:Int
    
    var Value : Int{
        switch Reason{
        case "獎勵總計":
            return MA + MB + MC
        case "懲戒總計":
            return DA + DB + DC
        case "大功":
            return MA
        case "小功":
            return MB
        case "嘉獎":
            return MC
        case "大過":
            return DA
        case "小過":
            return DB
        case "警告":
            return DC
        default:
            return 0
        }
    }
}

enum DisciplineType : Int{
    case Merit,Demerit
}

class MeritItemCell : UITableViewCell{
    
    @IBOutlet weak var Status1: UILabel!
    @IBOutlet weak var Status2: UILabel!
    @IBOutlet weak var Status3: UILabel!
    @IBOutlet weak var Date: UILabel!
    @IBOutlet weak var Reason: UILabel!
    
    override func awakeFromNib() {
        
        Status1.layer.masksToBounds = true
        Status1.layer.cornerRadius = Status1.frame.width / 2
        Status2.layer.masksToBounds = true
        Status2.layer.cornerRadius = Status1.frame.width / 2
        Status3.layer.masksToBounds = true
        Status3.layer.cornerRadius = Status1.frame.width / 2
    }
}

class DemeritItemCell : UITableViewCell{
    
    @IBOutlet weak var Status1: UILabel!
    @IBOutlet weak var Status2: UILabel!
    @IBOutlet weak var Status3: UILabel!
    @IBOutlet weak var Date: UILabel!
    @IBOutlet weak var Reason: UILabel!
    
    override func awakeFromNib() {
        
        Status1.layer.masksToBounds = true
        Status1.layer.cornerRadius = Status1.frame.width / 2
        Status2.layer.masksToBounds = true
        Status2.layer.cornerRadius = Status1.frame.width / 2
        Status3.layer.masksToBounds = true
        Status3.layer.cornerRadius = Status1.frame.width / 2
    }
}
