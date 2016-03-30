import UIKit
import Security

var kSecClassValue = NSString(format: kSecClass)
let kSecAttrAccountValue = NSString(format: kSecAttrAccount)
let kSecValueDataValue = NSString(format: kSecValueData)
let kSecReturnDataValue = NSString(format: kSecReturnData)
let kSecMatchLimitValue = NSString(format: kSecMatchLimit)
let kSecClassGenericPasswordValue = NSString(format: kSecClassGenericPassword)
let kSecMatchLimitOneValue = NSString(format: kSecMatchLimitOne)

public class Keychain {
    
    private var service = ""
    private var group = ""
    
    private static var notAllowKey = [Key.RefreshToken.rawValue,Key.CurrentIdenty.rawValue]
    
    enum Key : String{
        
        case RefreshToken = "refreshToken"
        case CurrentIdenty = "currentIdenty"
    }
    
    public class func save(key: String, data: NSData) -> Bool{
        
        if notAllowKey.contains(key){
            return false
        }
        
        return mainSave(key, data: data)
    }
    
    class func mainSave(key: String, data: NSData) -> Bool {
        let query = [
            kSecClassValue : kSecClassGenericPasswordValue,
            kSecAttrAccountValue : key,
            kSecValueDataValue : data ]
        
        SecItemDelete(query as CFDictionaryRef)
        
        let status: OSStatus = SecItemAdd(query as CFDictionaryRef, nil)
        
        return status == noErr
    }
    
    public class func load(key: String) -> NSData? {
        let query = [
            kSecClassValue       : kSecClassGenericPasswordValue,
            kSecAttrAccountValue : key,
            kSecReturnDataValue  : kCFBooleanTrue,
            kSecMatchLimitValue  : kSecMatchLimitOneValue ]
        
        //        let dataTypeRef : UnsafeMutablePointer<AnyObject?>
        //
        //        let status: OSStatus = SecItemCopyMatching(query, dataTypeRef)
        //
        //        if status == noErr {
        //            return (dataTypeRef.takeRetainedValue() as! NSData)
        //        } else {
        //            return nil
        //        }
        
        var data: AnyObject?
        
        let status = withUnsafeMutablePointer(&data) {
            SecItemCopyMatching(query, UnsafeMutablePointer($0))
        }
        if status == errSecSuccess {
            return data as? NSData
        } else {
            return nil
        }
    }
    
    public class func delete(key: String) -> Bool{
        
        if notAllowKey.contains(key){
            return false
        }
        
        return mainDelete(key)
    }
    
    class func mainDelete(key: String) -> Bool {
        let query = [
            kSecClassValue       : kSecClassGenericPasswordValue,
            kSecAttrAccountValue : key ]
        
        let status: OSStatus = SecItemDelete(query as CFDictionaryRef)
        
        return status == noErr
    }
    
    
    class func clear() -> Bool {
        let query = [ kSecClassValue : kSecClassGenericPasswordValue ]
        
        let status: OSStatus = SecItemDelete(query as CFDictionaryRef)
        
        return status == noErr
    }
}