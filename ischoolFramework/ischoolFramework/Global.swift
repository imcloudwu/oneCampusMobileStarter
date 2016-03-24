let frameworkBundle = NSBundle(identifier: "tw.ischool.ischoolFramework")

let frameworkStoryboard = UIStoryboard(name: "Storyboard", bundle: frameworkBundle)

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

func ShowErrorAlert(vc:UIViewController,title:String,msg:String){
        
    let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.Alert)
    
    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
    
    vc.presentViewController(alert, animated: true, completion: nil)
}
