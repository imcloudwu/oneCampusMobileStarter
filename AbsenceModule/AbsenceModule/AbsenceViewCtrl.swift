//
//  AbsenceViewCtrl.swift
//  AbsenceModule
//
//  Created by Cloud on 2016/3/10.
//  Copyright © 2016年 ischool. All rights reserved.
//

import UIKit
import ischoolFramework

class AbsenceViewCtrl : ischoolViewCtrl,UITableViewDelegate,UITableViewDataSource{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var segment: UISegmentedControl!
    
    let contract = "1campus.mobile.parent"
    
    var _data : [AttendanceItem]!
    var _displayDataBase : [AttendanceItem]!
    var _displayData : [AttendanceItem]!
    var _semesters : [SemesterItem]!
    var _currentSemester : SemesterItem?
    
    var _SegmentItems : [String]!
    
    @IBAction func SegmentSelect(sender: AnyObject) {
        
        let type = _SegmentItems[segment.selectedSegmentIndex]
        
        self._displayData = type == "總計" ? self._displayDataBase : self._displayDataBase.filter({ data in
            
            if data.AbsenceType == type{
                return true
            }
            
            return false
        })
        
        self.tableView.reloadDataWithAnimated()
    }
    
    func ChangeSemester(){
        let actionSheet = UIAlertController(title: "請選擇學年度學期", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
        actionSheet.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
        
        for semester in _semesters{
            actionSheet.addAction(UIAlertAction(title: semester.Description, style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                self.SetDataToTableView(semester)
            }))
        }
        
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
        
        return _currentSemester?.Description
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        let data = _displayData[indexPath.row]
        
        //處理summmary item
        if data.SchoolYear == "" && data.Semester == ""{
            var cell = tableView.dequeueReusableCellWithIdentifier("summaryItem")
            
            if cell == nil{
                cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "summaryItem")
                cell?.textLabel?.textColor = UIColor(red: 19/255, green: 144/255, blue: 255/255, alpha: 1)
            }
            
            cell!.textLabel?.text = data.AbsenceType
            cell!.detailTextLabel?.text = "\(_displayData[indexPath.row].Value)"
            
            return cell!
        }
        
        //處理一般的cell
        let cell = tableView.dequeueReusableCellWithIdentifier("AttendanceItemCell") as! AttendanceItemCell
        
        cell.Date.text = data.OccurDate
        cell.Type.text = data.AbsenceType
        cell.Count.text = "\(data.Value)"
        cell.Periods.text = data.Period
        
        return cell

    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return _displayData.count
    }
    
    override func viewWillAppear(animated: Bool) {
        
        _data = [AttendanceItem]()
        _displayDataBase = [AttendanceItem]()
        _displayData = [AttendanceItem]()
        _semesters = [SemesterItem]()
        _currentSemester = nil
        
        _SegmentItems = [String]()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Search, target: self, action: "ChangeSemester")
        
        tableView.estimatedRowHeight = 46.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        segment.removeAllSegments()
        segment.translatesAutoresizingMaskIntoConstraints = true
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.reloadData()
        
        GetAttendanceData()
    }
    
    override func StudentIdChanged(studentId: String) {
        
        appContext?.Id = studentId
        
        viewWillAppear(true)
    }
    
    override func DsnsChanged(dsns: String) {
        
        appContext?.Dsns = dsns
        
        viewWillAppear(true)
    }
    
    func GetAttendanceData() {
        
        var retVal = [AttendanceItem]()
        
        if let id = appContext?.Id where !id.isEmpty{
            
            appContext?.SendRequest(contract, srevice: "absence.GetChildAttendance", req: "<Request><RefStudentId>\(id)</RefStudentId></Request>", callback: { (response) -> () in
                
                let xml = try? AEXMLDocument(xmlData: response.dataValue)
                
                if let attendances = xml?.root["Response"]["Attendance"].all {
                    
                    for attendance in attendances{
                        
                        let occurDate = attendance.attributes["OccurDate"]
                        
                        let schoolYear = attendance.attributes["SchoolYear"]
                        
                        let semester = attendance.attributes["Semester"]
                        
                        if let periods = attendance["Detail"]["Period"].all {
                            
                            for period in periods{
                                
                                let absenceType = period.attributes["AbsenceType"]
                                
                                let periodName = period.stringValue
                                
                                let item = AttendanceItem(OccurDate: occurDate!, SchoolYear: schoolYear!, Semester: semester!, AbsenceType: absenceType!, Period: periodName, Value: 1)
                                
                                retVal.append(item)
                            }
                        }
                    }
                }
                
                self._data = retVal
                
                self.GetSemesters()
                
                if self._semesters.count > 0{
                    self.SetDataToTableView(self._semesters[0])
                }
                
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
        
        self._semesters = retVal.sort({$0 > $1})
    }
    
    func SetDataToTableView(semester:SemesterItem){
        
        self._currentSemester = semester
        var newData = [AttendanceItem]()
        var tmpData = [String:AttendanceItem]()
        
        for data in self._data{
            if data.SchoolYear == semester.SchoolYear && data.Semester == semester.Semester{
                
                //先合併同一天的假別
                let key = data.OccurDate + "_" + data.AbsenceType
                
                if tmpData[key] == nil{
                    tmpData[key] = data
                }
                else{
                    tmpData[key]?.Period += ",\(data.Period)"
                    tmpData[key]?.Value += data.Value
                }
            }
        }
        
        newData = Array(tmpData.values)
        
        newData = newData.sort{$0.OccurDate > $1.OccurDate}
        
        var sum = [String:Int]()
        
        //統計相同假別的數量
        for data in newData{
            if sum[data.AbsenceType] == nil{
                sum[data.AbsenceType] = 0
            }
            
            sum[data.AbsenceType]? += data.Value
        }
        
        var total = 0
        
        segment.removeAllSegments()
        _SegmentItems.removeAll(keepCapacity: false)
        
        //按個別假別種類建立一個summary item
        for s in sum{
            total += s.1
            
            segment.insertSegmentWithTitle("\(s.0)(\(s.1))", atIndex: 0, animated: false)
            _SegmentItems.insert(s.0, atIndex: 0)
        }
        
        segment.insertSegmentWithTitle("總計(\(total))", atIndex: 0, animated: true)
        _SegmentItems.insert("總計", atIndex: 0)
        
        SetSegmentWidth()
        
        self._displayData = newData
        self._displayDataBase = newData
        
        if self._SegmentItems.count > 0{
            segment.selectedSegmentIndex = 0
            SegmentSelect(self)
        }
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

struct AttendanceItem{
    var OccurDate : String
    var SchoolYear : String
    var Semester : String
    var AbsenceType : String
    var Period : String
    var Value : Int
}

class AttendanceItemCell : UITableViewCell{
    
    @IBOutlet weak var Date: UILabel!
    @IBOutlet weak var Type: UILabel!
    @IBOutlet weak var Periods: UILabel!
    @IBOutlet weak var Count: UILabel!
    
    override func awakeFromNib() {
        
        Count.layer.masksToBounds = true
        
        Count.layer.cornerRadius = Count.frame.width / 2
    }
}