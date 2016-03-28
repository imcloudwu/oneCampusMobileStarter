//
//  ScanCodeViewCtrl.swift
//  oneCampusParent
//
//  Created by Cloud on 8/25/15.
//  Copyright (c) 2015 ischool. All rights reserved.
//

import UIKit
import AVFoundation

class ScanCodeViewCtrl: UIViewController,AVCaptureMetadataOutputObjectsDelegate {
    
    var _captureSession: AVCaptureSession? = nil
    var _videoPreviewLayer: AVCaptureVideoPreviewLayer? = nil
    
    @IBOutlet var _videoPreview: UIView!
    
    var _DsnsItem : DsnsItem!
    var _Code : String!
    
    var Resource : Resources!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _videoPreview.layer.masksToBounds = true
        _videoPreview.layer.cornerRadius = 5
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        
        startReading()
    }
    
    override func viewWillDisappear(animated: Bool) {
        stopReading()
    }
    
    func startReading() -> Bool{
        
        //lblResult.text = "Scanning..."
        
        let captureDevice: AVCaptureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        let input: AVCaptureDeviceInput?
        
        do {
            input = try AVCaptureDeviceInput(device: captureDevice)
        } catch _ as NSError {
            input = nil
        }
        
        let output: AVCaptureMetadataOutput = AVCaptureMetadataOutput()
        
        _captureSession = AVCaptureSession()
        _captureSession?.addInput(input)
        _captureSession?.addOutput(output)
        
        let dispatchQueue: dispatch_queue_t = dispatch_queue_create("myQueue", nil);
        
        output.setMetadataObjectsDelegate(self, queue: dispatchQueue)
        output.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        
        _videoPreviewLayer = AVCaptureVideoPreviewLayer(session: _captureSession)
        _videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        _videoPreviewLayer?.frame = _videoPreview.layer.bounds
        
        _videoPreview.layer.addSublayer(_videoPreviewLayer!)
        
        _captureSession?.startRunning()
        
        return true
    }
    
    func stopReading() {
        _captureSession?.stopRunning()
        _captureSession = nil
        
        _videoPreviewLayer?.removeFromSuperlayer()
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!){
        
        if metadataObjects != nil && metadataObjects.count > 0 {
            let metadataObj: AVMetadataMachineReadableCodeObject = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
            
            dispatch_async(dispatch_get_main_queue()) {() -> Void in
                
                let fullNameArr = metadataObj.stringValue.componentsSeparatedByString("@")
                
                if fullNameArr.count == 2{
                    
                    self._Code = fullNameArr[0]
                    let server:String = fullNameArr[1]
                    
                    self.AddApplicationRef(server)
                }
                else{
                    ShowErrorAlert(self, title: "系統提示", msg: "代碼格式不正確")
                }
            }
            
            stopReading()
        }
        
    }
    
    func AddApplicationRef(server:String){
        
        self._DsnsItem = DsnsItem(name: server, accessPoint: server)
        
        if !DsnsManager.Singleton.DsnsList.contains(self._DsnsItem){
            
            let _ = try? Resource.Connection.SendRequest("https://auth.ischool.com.tw:8443/dsa/greening", contract: "user", service: "AddApplicationRef", body: "<Request><Applications><Application><AccessPoint>\(server)</AccessPoint><Type>dynpkg</Type></Application></Applications></Request>")
            
            DsnsManager.Singleton.DsnsList.append(self._DsnsItem)
            
            Resource.Connection.loginHelper.TryToChangeScope(self, after: { () -> Void in
                
                self.JoinAsParent()
            })
        }
        else{
            
            JoinAsParent()
        }
    }
    
    func JoinAsParent(){
        
        var rsp : String
        
        do{
            rsp = try Resource.Connection.SendRequest(self._DsnsItem.AccessPoint, contract: "auth.guest", service: "Join.AsParent", body: "<Request><ParentCode>\(_Code)</ParentCode><Relationship>iOS Parent</Relationship></Request>")
        }
        catch ConnectionError.connectError(let reason){
            ShowErrorAlert(self, title: "加入失敗", msg: reason)
            return
        }
        catch{
            ShowErrorAlert(self, title: "加入失敗", msg: "發生不明的錯誤,請回報給開發人員")
            return
        }
        
        let xml: AEXMLDocument?
        
        do {
            xml = try AEXMLDocument(xmlData: rsp.dataValue)
        } catch _ {
            xml = nil
        }
        
        if let _ = xml?.root["Body"]["Success"]{
            
            let alert = UIAlertController(title: "加入成功", message: "", preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIAlertAction(title: "確認", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                
                self.navigationController?.popViewControllerAnimated(true)
            }))
            
            self.presentViewController(alert, animated: true, completion: nil)
            
        }
        else{
            ShowErrorAlert(self, title: "加入失敗", msg: "發生不明的錯誤,請回報給開發人員")
        }
        
    }
    
}
