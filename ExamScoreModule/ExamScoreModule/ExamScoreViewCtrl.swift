//
//  ExamScoreViewCtrl.swift
//  ExamScoreModule
//
//  Created by Cloud on 2016/3/15.
//  Copyright © 2016年 ischool. All rights reserved.
//

import UIKit
import ischoolFramework

class ExamScoreViewCtrl : ischoolViewCtrl,UITableViewDataSource,UITableViewDelegate{
    
    var contract : String!
    var scoreCalcRule_service : String!
    var scoreJH_service : String!
    var scoreSH_service : String!
    
    var _isJH : Bool!
    var _isHS : Bool!
    var _SubjectScales : Int16!
    var _DomainScales : Int16!
    
    var _CurrentSemester : SemesterItem!
    var _ExamList : [String]!
    var _CurrentExam : String!
    
    var _data : [ExamScoreItem]!
    var _displayData : [DisplayItem]!
    var _Semesters : [SemesterItem]!
    
    var ExamBtn : UIBarButtonItem!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewWillAppear(animated: Bool) {
        
        _isJH = false
        _isHS = false
        _SubjectScales  = 2
        _DomainScales  = 2
        
        _CurrentSemester = nil
        _ExamList = [String]()
        _CurrentExam = ""
        
        _data = [ExamScoreItem]()
        _displayData = [DisplayItem]()
        _Semesters = [SemesterItem]()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.reloadData()
        
        ExamBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: "ChangeExam")
        ExamBtn.enabled = false
        
        let changeSemesterBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Search, target: self, action: "ChangeSemester")
        
        self.navigationItem.rightBarButtonItems = [changeSemesterBtn,ExamBtn]
            
        self.CheckDSNS()
        
        if let identy = appContext?.Identy {
            
            switch(identy){
                
            case .Admin:
                SetContractAndServiceName(adminContract, scoreCalcRule_service: admin_scoreCalcRule_service, scoreJH_service: admin_scoreJH_service, scoreSH_service: admin_scoreSH_service)
                GetData()
                
            case .ClassTeacher:
                SetContractAndServiceName(teacherContract, scoreCalcRule_service: teacher_scoreCalcRule_service, scoreJH_service: teacher_scoreJH_service, scoreSH_service: teacher_scoreSH_service)
                GetData()
                
            case .CourseTeacher:
                SetContractAndServiceName(teacherContract, scoreCalcRule_service: teacher_scoreCalcRule_service, scoreJH_service: teacher_scoreJH_service, scoreSH_service: teacher_scoreSH_service)
                GetExamScoreDataByCourseTeacher()
                
            default:
                SetContractAndServiceName(parentContract, scoreCalcRule_service: parent_scoreCalcRule_service, scoreJH_service: parent_scoreJH_service, scoreSH_service: parent_scoreSH_service)
                GetData()
            }
        }
    }
    
    func SetContractAndServiceName(contract:String,scoreCalcRule_service:String,scoreJH_service:String,scoreSH_service:String){
        
        self.contract = contract
        self.scoreCalcRule_service = scoreCalcRule_service
        self.scoreJH_service = scoreJH_service
        self.scoreSH_service = scoreSH_service
    }
    
    func GetData(){
        
        if self._isJH == true{
            self.SetScoreCalcRule()
            GetJHData()
        }
        else{
            GetSHData()
        }
    }
    
    //new solution
    func CheckDSNS() {
        
        self._isJH = false
        self._isHS = false
        
        if let dsns = appContext?.Dsns?.UrlEncoding where !dsns.isEmpty{
            
            let data = try? HttpClient.Get("http://dsns.1campus.net/campusman.ischool.com.tw/config.public/GetSchoolList?content=%3CRequest%3E%3CMatch%3E\(dsns)%3C/Match%3E%3CPagination%3E%3CPageSize%3E10%3C/PageSize%3E%3CStartPage%3E1%3C/StartPage%3E%3C/Pagination%3E%3C/Request%3E")
            
            if let rsp = data{
                
                let xml: AEXMLDocument?
                
                do {
                    xml = try AEXMLDocument(xmlData: rsp)
                } catch _ {
                    xml = nil
                }
                
                if let coreSystem = xml?.root["Response"]["School"]["CoreSystem"].stringValue{
                    
                    if coreSystem == "國中新竹" || coreSystem == "實驗雙語部"{
                        self._isJH = true
                        self._isHS = true
                    }
                    else if coreSystem == "國中高雄"{
                        self._isJH = true
                    }
                    
                }
            }
        }
    }
    
    func SetScoreCalcRule(){
        
        if let student_id = appContext?.Id where !student_id.isEmpty{
            
            appContext?.SendRequest(contract, srevice: scoreCalcRule_service, req: "<Request><StudentID>\(student_id)</StudentID></Request>", successCallback: { (response) -> () in
                
                let xml: AEXMLDocument?
                
                do {
                    xml = try AEXMLDocument(xmlData: response.dataValue)
                } catch _ {
                    xml = nil
                }
                
                if let subjectScales = xml?.root["ScoreCalcRule"]["SubjectScales"].stringValue{
                    self._SubjectScales = subjectScales.int16Value
                }
                
                if let domainScales = xml?.root["ScoreCalcRule"]["DomainScales"].stringValue{
                    self._DomainScales = domainScales.int16Value
                }
                }, failureCallback: { (error) -> () in
                    
                    print(error)
            })
        }
    }
    
    //取得高中資料
    func GetSHData(){
        
        var retVal = [ExamScoreItem]()
        
        if let student_id = appContext?.Id where !student_id.isEmpty{
            
            appContext?.SendRequest(contract, srevice: scoreSH_service, req: "<Request><Condition><StudentID>\(student_id)</StudentID></Condition></Request>", successCallback: { (response) -> () in
                
                let xml: AEXMLDocument?
                do {
                    xml = try AEXMLDocument(xmlData: response.dataValue)
                } catch _ {
                    xml = nil
                }
                
                if let semes = xml?.root["ExamScoreList"]["Seme"].all{
                    for seme in semes{
                        let schoolYear = seme.attributes["SchoolYear"]
                        let semester = seme.attributes["Semester"]
                        
                        if let courses = seme["Course"].all{
                            for course in courses{
                                
                                let courseID = course.attributes["CourseID"]
                                let subject = course.attributes["Subject"]
                                let credit = course.attributes["Credit"]
                                
                                if let exams = course["Exam"].all{
                                    for exam in exams{
                                        let examDisplayOrder = exam.attributes["ExamDisplayOrder"]?.intValue
                                        let examId = exam.attributes["ExamID"]
                                        let examName = exam.attributes["ExamName"]
                                        let score = exam["ScoreDetail"].attributes["Score"]
                                        
                                        let item = ExamScoreItem(SchoolYear: schoolYear!, Semester: semester!, CourseID: courseID!,Domain: "", Subject: subject!, Credit: credit!, ExamId: examId!, ExamName: examName!, Score: score!, AssignmentScore: "", DisplayOrder: examDisplayOrder!, ScorePercentage: 0)
                                        
                                        retVal.append(item)
                                    }
                                }
                            }
                            
                        }
                        
                    }
                }
                
                self._data = retVal
                
                self.GetSemesters()
                }, failureCallback: { (error) -> () in
                    
                    print(error)
            })
        }
    }
    
    //取得國中資料
    func GetJHData(){
        
        var retVal = [ExamScoreItem]()
        
        if let student_id = appContext?.Id where !student_id.isEmpty{
            
            appContext?.SendRequest(contract, srevice: scoreJH_service, req: "<Request><Condition><StudentID>\(student_id)</StudentID></Condition></Request>", successCallback: { (response) -> () in
                
                let xml: AEXMLDocument?
                do {
                    xml = try AEXMLDocument(xmlData: response.dataValue)
                } catch _ {
                    xml = nil
                }
                
                if let semes = xml?.root["ExamScoreList"]["Seme"].all{
                    for seme in semes{
                        let schoolYear = seme.attributes["SchoolYear"]
                        let semester = seme.attributes["Semester"]
                        
                        if let courses = seme["Course"].all{
                            
                            for course in courses{
                                
                                let courseID = course.attributes["CourseID"]
                                let subject = course.attributes["Subject"]
                                let credit = course.attributes["Credit"]
                                let domain = course.attributes["Domain"]
                                
                                let scorePercentage = course["FixTime"]["Extension"]["ScorePercentage"].stringValue.doubleValue
                                
                                //針對高雄的資料新增平時成績
                                if !self._isHS , let ordinarilyScore = course["FixExtension"]["Extension"]["OrdinarilyScore"].first?.stringValue{
                                    let item = ExamScoreItem(SchoolYear: schoolYear!, Semester: semester!, CourseID: courseID!, Domain: domain!, Subject: subject!, Credit: credit!, ExamId: "", ExamName: "平時成績", Score: ordinarilyScore, AssignmentScore: "", DisplayOrder: 99, ScorePercentage: scorePercentage)
                                    
                                    retVal.append(item)
                                }
                                
                                if let exams = course["Exam"].all{
                                    for exam in exams{
                                        let examDisplayOrder = exam.attributes["ExamDisplayOrder"]?.intValue
                                        let examId = exam.attributes["ExamID"]
                                        let examName = exam.attributes["ExamName"]
                                        var score = ""
                                        var assignmentScore = ""
                                        
                                        if let tmpScore = exam["ScoreDetail"]["Extension"]["Extension"]["Score"].first?.stringValue{
                                            score = tmpScore
                                        }
                                        
                                        if let tmpAssignmentScore = exam["ScoreDetail"]["Extension"]["Extension"]["AssignmentScore"].first?.stringValue{
                                            assignmentScore = tmpAssignmentScore
                                        }
                                        
                                        let item = ExamScoreItem(SchoolYear: schoolYear!, Semester: semester!, CourseID: courseID!, Domain: domain!, Subject: subject!, Credit: credit!, ExamId: examId!, ExamName: examName!, Score: score, AssignmentScore: assignmentScore, DisplayOrder: examDisplayOrder!, ScorePercentage: scorePercentage)
                                        
                                        retVal.append(item)
                                    }
                                }
                            }
                        }
                    }
                }
                
                self._data = retVal
                
                self.GetSemesters()
                
                }, failureCallback: { (error) -> () in
                    
                    print(error)
            })
        }
    }

    
    func ChangeSemester(){
        let actionSheet = UIAlertController(title: "請選擇學年度學期", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
        actionSheet.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
        
        for semester in _Semesters{
            actionSheet.addAction(UIAlertAction(title: semester.Description, style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                
                self.SelectSemester(semester)
                
            }))
        }
        
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    func ChangeExam(){

        let actionSheet = UIAlertController(title: "請選擇考試別", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
        actionSheet.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
        
        for exam in _ExamList{
            actionSheet.addAction(UIAlertAction(title: exam, style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                
                self.SetJHDataToTableView(exam)
                
            }))
        }
        
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    func SelectSemester(semester:SemesterItem){
        
        self._CurrentSemester = semester
        
        if _isJH == true{
            _ExamList.removeAll(keepCapacity: false)
            
            let datas = GetMatchExamScoreItem(nil)
            
            for data in datas{
                if !_ExamList.contains(data.ExamName){
                    _ExamList.append(data.ExamName)
                }
            }
            
            if _ExamList.count > 0{
                SetJHDataToTableView(_ExamList[0])
            }
            
            CheckExamBtn()
        }
        else{
            SetSHDataToTableView()
        }
    }
    
    func SetJHDataToTableView(examName : String){
        
        self._CurrentExam = examName
        var displayData = [DisplayItem]()
        
        let matchDatas = GetMatchExamScoreItem(examName)
        let domains = GetDomainList(matchDatas)
        
        //將相同領域的資料排在一起
        var collections = [String:[ExamScoreItem]]()
        for mData in matchDatas{
            if collections[mData.Domain] == nil{
                collections[mData.Domain] = [ExamScoreItem]()
            }
            
            collections[mData.Domain]?.append(mData)
        }
        
        //按領域順序呈現
        for domain in domains{
            
            //displayData.append(DisplayItem(Title: domain.Name, Value: "socre here", OtherInfo: "summaryItem", ColorAlarm: false))
            
            let items : [ExamScoreItem] = collections[domain.Name]!
            
            var sumCredit = Double(0)
            var sumScore = Double(0)
            
            var mustAppendItem = [DisplayItem]()
            
            for item in items{
                let data = item
                var avg = data.GetJHScore()
                
                if !avg.isNaN{
                    
                    avg = avg.Round(_SubjectScales)
                    
                    let di = DisplayItem(Title: data.Subject, Value: "\(avg.ToString(_SubjectScales))", OtherInfo: "定期 : \(data.Score)", OtherInfo2: "平時 : \(data.AssignmentScore)", OtherInfo3: "權數 : \(data.Credit)", ColorAlarm: avg < 60)
                    
                    di.OtherObject = item
                    
                    mustAppendItem.append(di)
                    
                    sumCredit += data.Credit.doubleValue
                    sumScore += data.Credit.doubleValue * avg
                }
            }
            
            var sumAvg = sumScore / sumCredit
            
            if !sumAvg.isNaN{
                
                sumAvg = sumAvg.Round(_DomainScales)
                displayData.append(DisplayItem(Title: domain.Name, Value: sumAvg.ToString(_DomainScales), OtherInfo: "summaryItem", ColorAlarm: sumAvg < 60))
                
                displayData += mustAppendItem
            }
        }
        
        _displayData = displayData
        
        tableView.reloadDataWithAnimated()
    }
    
    func SetSHDataToTableView(){
        
        var displayData = [DisplayItem]()
        
        let matchDatas = GetMatchExamScoreItem(nil)
        let subjects = GetSubjectList(matchDatas)
        
        //將相同課程的資料排在一起
        var collections = [String:[ExamScoreItem]]()
        for mData in matchDatas{
            if collections[mData.CourseID] == nil{
                collections[mData.CourseID] = [ExamScoreItem]()
            }
            
            collections[mData.CourseID]?.append(mData)
        }
        
        //按科目順序呈現
        for subject in subjects{
            
            displayData.append(DisplayItem(Title: subject.Name, Value: "", OtherInfo: "summaryItem", ColorAlarm: false))
            
            let items : [ExamScoreItem] = collections[subject.CourseID]!
            
            //items.sort({$0.DisplayOrder < $1.DisplayOrder})
            
            var lastScore = Double.NaN
            for item in items{
                var result : String!
                let scoreValue = item.GetSHScore()
                
                if lastScore.isNaN || scoreValue.isNaN || scoreValue == lastScore{
                    result = "event"
                }
                else if scoreValue > lastScore{
                    result = "up"
                }
                else{
                    result = "down"
                }
                
                lastScore = scoreValue
                
                let di = DisplayItem(Title: item.ExamName, Value: item.Score, OtherInfo: result, OtherInfo2: "", OtherInfo3: "", ColorAlarm: scoreValue < 60)
                
                di.OtherObject = item
                
                displayData.append(di)
            }
        }
        
        _displayData = displayData
        
        tableView.reloadDataWithAnimated()
    }
    
    func GetMatchExamScoreItem(examName:String?) -> [ExamScoreItem]{
        
        var retVal = [ExamScoreItem]()
        
        if examName == nil{
            for data in _data{
                if data.SchoolYear == _CurrentSemester.SchoolYear && data.Semester == _CurrentSemester.Semester{
                    retVal.append(data)
                }
            }
        }
        else{
            for data in _data{
                if data.SchoolYear == _CurrentSemester.SchoolYear && data.Semester == _CurrentSemester.Semester && data.ExamName == examName{
                    retVal.append(data)
                }
            }
        }
        
        if _isJH == true{
            retVal = retVal.sort({$0.DisplayOrder < $1.DisplayOrder})
        }
        
        return retVal
    }
    
    func GetSubjectList(sourceDatas:[ExamScoreItem]) -> [Subject]{
        
        var retVal = [Subject]()
        
        for data in sourceDatas{
            let subject = Subject(CourseID: data.CourseID,Name: data.Subject)
            
            if !retVal.contains(subject){
                retVal.append(subject)
            }
        }
        
        //retVal.sort({$0.CourseID < $1.CourseID})
        
        return retVal
    }
    
    func GetDomainList(sourceDatas:[ExamScoreItem]) -> [Domain]{
        
        var retVal = [Domain]()
        
        for data in sourceDatas{
            let domain = Domain(Name: data.Domain)
            
            if !retVal.contains(domain){
                retVal.append(domain)
            }
        }
        
        return retVal
    }
    
    func CheckExamBtn(){
        if _ExamList.count > 0{
            ExamBtn.enabled = true
        }
        else{
            ExamBtn.enabled = false
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return _displayData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        let data = _displayData[indexPath.row]
        
        if data.OtherInfo == "summaryItem"{
            
            var cell = tableView.dequeueReusableCellWithIdentifier("summaryItem")
            
            if cell == nil{
                cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "summaryItem")
                cell?.backgroundColor = UIColor(red: 219/255, green: 228/255, blue: 238/255, alpha: 1)
                //cell?.textLabel?.textColor = UIColor(red: 19/255, green: 144/255, blue: 255/255, alpha: 1)
            }
            
            cell!.textLabel?.text = data.Title
            cell!.detailTextLabel?.text = data.Value
            
            if data.ColorAlarm{
                cell!.detailTextLabel?.textColor = UIColor.redColor()
            }
            else{
                cell!.detailTextLabel?.textColor = UIColor.darkGrayColor()
            }
            
            return cell!
            
        }else{
            
            if _isJH == true{
                
                let cell = tableView.dequeueReusableCellWithIdentifier("examScoreMoreInfoItemCell") as! ExamScoreMoreInfoItemCell
                
                cell.ExamName.text = data.Title
                cell.Score.text = data.Value
                cell.Info1.text = data.OtherInfo
                cell.Info2.text = data.OtherInfo2
                cell.Info3.text = data.OtherInfo3
                
                if _isHS == true{
                    cell.Info1.hidden = false
                    cell.Info2.hidden = false
                }
                else{
                    cell.Info1.hidden = true
                    cell.Info2.hidden = true
                }
                
                if data.ColorAlarm{
                    cell.Score.textColor = UIColor.redColor()
                }
                else{
                    cell.Score.textColor = UIColor.blackColor()
                }
                
                return cell
            }
            else{
                
                let cell = tableView.dequeueReusableCellWithIdentifier("examScoreItemCell") as! ExamScoreItemCell
                
                if cell.accessoryView == nil{
                    let lab = UILabel(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
                    lab.textAlignment = NSTextAlignment.Center
                    cell.accessoryView = lab
                }
                
                cell.ExamName.text = data.Title
                cell.Score.text = data.Value
                
                let lab = cell.accessoryView as! UILabel
                
                if data.OtherInfo == "up"{
                    lab.text = "↑"
                    lab.textColor = UIColor.greenColor()
                }
                else if data.OtherInfo == "down"{
                    lab.text = "↓"
                    lab.textColor = UIColor.redColor()
                }
                else{
                    lab.text = ""
                }
                
                if data.ColorAlarm{
                    cell.Score.textColor = UIColor.redColor()
                }
                else{
                    cell.Score.textColor = UIColor.blackColor()
                }
                
                return cell
            }
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title = ""
        
        if let description = _CurrentSemester?.Description{
            title += description
        }
        
        title += " \(_CurrentExam)"
        
        if title == " "{
            return nil
        }
        
        return title
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        
        if _displayData[indexPath.row].OtherInfo == "summaryItem"{
            return 30
        }
        
        return _isJH == true ? 50 : 30
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
        
        if self._Semesters.count > 0{
            self.SelectSemester(self._Semesters[0])
        }
    }
    
    //for Course Teacher
    func GetExamScoreDataByCourseTeacher(){
        
        var retVal = [DisplayItem]()
        
        if let id = appContext?.Id,let data = appContext?.Data{
            
            appContext?.SendRequest(teacherContract, srevice: "courseTeacher.GetExamScore", req: "<Request><Condition><RefStudentId>\(id)</RefStudentId><RefCourseId>\(data.ClassID)</RefCourseId></Condition></Request>", successCallback: { (response) -> () in
                
                var xml: AEXMLDocument?
                
                do {
                    xml = try AEXMLDocument(xmlData: response.dataValue)
                } catch _ {
                    xml = nil
                }
                
                if let sceTakes = xml?.root["Response"]["SceTake"].all {
                    for sceTake in sceTakes{
                        let examName = sceTake["ExamName"].stringValue
                        
                        var examScore = ""
                        var assignmentScore = ""
                        
                        if self._isJH == true{
                            examScore = sceTake["Extension"]["Extension"]["Score"].stringValue
                        }
                        else{
                            examScore = sceTake["Score"].stringValue
                        }
                        
                        if self._isHS == true{
                            assignmentScore = sceTake["Extension"]["Extension"]["AssignmentScore"].stringValue
                        }
                        
                        retVal.append(DisplayItem(Title: examName, Value: examScore, OtherInfo: "", ColorAlarm: false))
                        
                        if assignmentScore != ""{
                            retVal.append(DisplayItem(Title: examName + "(平時)", Value: assignmentScore, OtherInfo: "", ColorAlarm: false))
                        }
                    }
                }
                
                self.GetCourseScoreDataByCourseTeacher(retVal)
                
                }, failureCallback: { (error) -> () in
                    
                    print(error)
                    
                    self.GetCourseScoreDataByCourseTeacher(retVal)
            })
        }
        
    }
    
    func GetCourseScoreDataByCourseTeacher(var retVal:[DisplayItem]){
        
        if let id = appContext?.Id,let data = appContext?.Data{
            
            appContext?.SendRequest(teacherContract, srevice: "courseTeacher.GetCourseScore", req: "<Request><Condition><RefStudentId>\(id)</RefStudentId><RefCourseId>\(data.ClassID)</RefCourseId></Condition></Request>", successCallback: { (response) -> () in
                
                var xml : AEXMLDocument?
                
                do {
                    xml = try AEXMLDocument(xmlData: response.dataValue)
                } catch _ {
                    xml = nil
                }
                
                let courseScore = xml?.root["Response"]["CourseScore"]["Score"].stringValue
                let ordinarilyScore = xml?.root["Response"]["CourseScore"]["Extension"]["Extension"]["OrdinarilyScore"].stringValue
                
                if self._isJH == false && courseScore != ""{
                    retVal.append(DisplayItem(Title: "課程成績", Value: courseScore!, OtherInfo: "", ColorAlarm: false))
                }
                
                if self._isJH == true && self._isHS == true && ordinarilyScore != ""{
                    retVal.append(DisplayItem(Title: "課程平時成績", Value: ordinarilyScore!, OtherInfo: "", ColorAlarm: false))
                }
                
                self._displayData = retVal
                
                self.tableView.reloadDataWithAnimated()
                
                }, failureCallback: { (error) -> () in
                    
                    print(error)
                    
                    self._displayData = retVal
                    
                    self.tableView.reloadDataWithAnimated()
            })
        }
    }
    
}

struct ExamScoreItem {
    var SchoolYear : String
    var Semester : String
    var CourseID : String
    var Domain : String
    var Subject : String
    var Credit : String
    var ExamId : String
    var ExamName : String
    var Score : String
    var AssignmentScore : String
    var DisplayOrder : Int
    var ScorePercentage : Double
    //var Avg:String
    
    func GetSHScore() -> Double{
        if Score.isEmpty{
            return Double.NaN
        }
        
        return Score.doubleValue
    }
    
    func GetJHScore() -> Double{
        
        if Score.isEmpty && AssignmentScore.isEmpty{
            return Double.NaN
        }
        else if Score.isEmpty && !AssignmentScore.isEmpty{
            return AssignmentScore.doubleValue
        }
        else if !Score.isEmpty && AssignmentScore.isEmpty{
            return Score.doubleValue
        }
        else{
            return (Score.doubleValue * ScorePercentage / 100) + (AssignmentScore.doubleValue * (100 - ScorePercentage) / 100)
        }
    }
}

struct Domain : Equatable{
    var Name : String
}

struct Subject : Equatable{
    var CourseID : String
    var Name : String
}

func ==(lhs: Domain, rhs: Domain) -> Bool {
    return lhs.Name == rhs.Name
}

func ==(lhs: Subject, rhs: Subject) -> Bool {
    return lhs.CourseID == rhs.CourseID && lhs.Name == rhs.Name
}

class ExamScoreItemCell : UITableViewCell{
    
    @IBOutlet weak var ExamName: UILabel!
    @IBOutlet weak var Score: UILabel!
    
    override func awakeFromNib() {
        //
    }
}

class ExamScoreMoreInfoItemCell : UITableViewCell{
    
    @IBOutlet weak var ExamName: UILabel!
    @IBOutlet weak var Score: UILabel!
    @IBOutlet weak var Info1: UILabel!
    @IBOutlet weak var Info2: UILabel!
    @IBOutlet weak var Info3: UILabel!
    
    override func awakeFromNib() {
        //
    }
}

class DisplayItem{
    var Title : String
    var Value : String
    var OtherInfo : String
    var OtherInfo2 : String
    var OtherInfo3 : String
    var ColorAlarm : Bool
    
    var OtherObject : Any!
    
    convenience init(Title:String,Value:String,OtherInfo:String,ColorAlarm:Bool){
        
        self.init(Title:Title,Value:Value,OtherInfo:OtherInfo,OtherInfo2:"",OtherInfo3:"",ColorAlarm:ColorAlarm)
    }
    
    init(Title:String,Value:String,OtherInfo:String,OtherInfo2:String,OtherInfo3:String,ColorAlarm:Bool){
        self.Title = Title
        self.Value = Value
        self.OtherInfo = OtherInfo
        self.OtherInfo2 = OtherInfo2
        self.OtherInfo3 = OtherInfo3
        self.ColorAlarm = ColorAlarm
    }
}

extension Double {
    
    //四捨五入到小數點第二位(前一位數是偶數時是五捨六入)
    //    func toString(precision : Int) -> String {
    //        return String(format: "%.\(precision)f", self)
    //    }
    
    func Round(precision : Int16) -> Double {
        let x = NSDecimalNumber(string: "\(self)")
        let y = NSDecimalNumber(int: 1)
        
        //小數點第二位四捨五入進位
        let behavior = NSDecimalNumberHandler(roundingMode: NSRoundingMode.RoundPlain, scale: precision, raiseOnExactness: true, raiseOnOverflow: true, raiseOnUnderflow: true, raiseOnDivideByZero: true)
        
        return x.decimalNumberByDividingBy(y, withBehavior: behavior).doubleValue
    }
    
    func ToString(precision : Int16) -> String {
        return String(format: "%.\(precision)f", self)
    }
}

