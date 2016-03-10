
let frameworkBundle = NSBundle(identifier: "tw.ischool.ischoolFramework")

let frameworkStoryboard = UIStoryboard(name: "Storyboard", bundle: frameworkBundle)

func GetMyChildren(resources:Resources,dsns:String) -> [Student]{
    
    var retVal = [Student]()
    
    let rsp = resources.Connection.SendRequest(dsns, contract: "1campus.mobile.parent", service: "main.GetMyChildren", body: "")
    
    let xml: AEXMLDocument?
    do {
        xml = try AEXMLDocument(xmlData: rsp.dataValue)
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
    
//    if retVal.count > 0{
//        
//        let schoolName = GetSchoolName(dsns)
//        
//        retVal.insert(Student(DSNS: "header", ID: "", ClassID: "", ClassName: schoolName, Name: "", SeatNo: "", StudentNumber: "", Gender: "", MailingAddress: "", PermanentAddress: "", ContactPhone: "", PermanentPhone: "", CustodianName: "", FatherName: "", MotherName: "", Photo: nil), atIndex: 0)
//    }
    
    return retVal
}

func GetDsnsList(accessToken:String) -> [DsnsItem]{
    
    var dsnsList = [DsnsItem]()
    
    var dserr : DSFault!
    
    let con = Connection()
    
    if con.connect("https://auth.ischool.com.tw:8443/dsa/greening", "user", SecurityToken.createOAuthToken(accessToken), &dserr){
        let rsp = con.sendRequest("GetApplicationListRef", bodyContent: "<Request><Type>dynpkg</Type></Request>", &dserr)
        
        let xml: AEXMLDocument?
        do {
            xml = try AEXMLDocument(xmlData: rsp.dataValue)
        } catch _ {
            xml = nil
        }
        //println(xml?.xmlString)
        
        if let apps = xml?.root["Response"]["User"]["App"].all {
            for app in apps{
                let title = app.attributes["Title"]
                let accessPoint = app.attributes["AccessPoint"]
                let dsns = DsnsItem(name: title!, accessPoint: accessPoint!)
                if !dsnsList.contains(dsns){
                    dsnsList.append(dsns)
                }
            }
        }
        
        if let apps = xml?.root["Response"]["Domain"]["App"].all {
            for app in apps{
                let title = app.attributes["Title"]
                let accessPoint = app.attributes["AccessPoint"]
                let dsns = DsnsItem(name: title!, accessPoint: accessPoint!)
                if !dsnsList.contains(dsns){
                    dsnsList.append(dsns)
                }
            }
        }
    }
    
    return dsnsList
}



func GetImageFromBase64String(base64String:String,defaultImg:UIImage?) -> UIImage?{
    
    var decodedimage : UIImage?
    
    if let decodedData = NSData(base64EncodedString: base64String, options: NSDataBase64DecodingOptions(rawValue: 0)){
        decodedimage = UIImage(data: decodedData)
    }
    
    return decodedimage ?? defaultImg
}

//new solution
func GetSchoolName(dsns:String) -> String{
    
    var schoolName = dsns
    
    //encode成功呼叫查詢
    if let encodingName = dsns.UrlEncoding{
        
        let data = try? HttpClient.Get("http://dsns.1campus.net/campusman.ischool.com.tw/config.public/GetSchoolList?content=%3CRequest%3E%3CMatch%3E\(encodingName)%3C/Match%3E%3CPagination%3E%3CPageSize%3E10%3C/PageSize%3E%3CStartPage%3E1%3C/StartPage%3E%3C/Pagination%3E%3C/Request%3E")
        
        if let rsp = data{
            
            let xml: AEXMLDocument?
            do {
                xml = try AEXMLDocument(xmlData: rsp)
            } catch _ {
                xml = nil
            }
            
            if let name = xml?.root["Response"]["School"]["Title"].stringValue{
                schoolName = name
            }
        }
    }
    
    return schoolName
}