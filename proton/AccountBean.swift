//
//  AccountBean.swift
//  sofa
//
//  Created by Li Wansheng on 2019/4/11.
//  Copyright © 2019年 com.nbs. All rights reserved.
//

import Foundation
import DecentralizedShadowSocks

class Account :NSObject{
        var password:String = ""
        var addr:String = ""
        var cipher:String = ""
        var ethAddr:String = ""
        
        var defaults = UserDefaults.standard
        var queue = DispatchQueue(label: "smart contract queue")
        override init() {
                super.init()
                loadAccount()
        }
        
        public func IsEmpty() -> Bool{
                return self.addr == ""
        }
        
        public func loadAccount(){
                guard let data = defaults.data(forKey: KEY_FOR_ACCOUNT_PATH) else{
                        return
                }
                
                if let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String : String] {
                        self.password = (json["PassWord"] != nil) ? json["PassWord"]! : ""
                        self.cipher = (json["CipherTxt"] != nil) ? json["CipherTxt"]! : ""
                        self.addr =  (json["Address"] != nil) ? json["Address"]! : ""
                }
                
                if self.addr != ""{
                        queue.async {
                                self.ethAddr = self.LoadEthAddrBySofaAddr(sofa: self.addr)
                        }
                }
        }
        
        func LoadEthAddrBySofaAddr(sofa:String) ->String{
                guard let ret = LibLoadEthAddrByProtonAddr(sofa.toGoString()) else{
                        return ""
                }
                return String(cString:ret).lowercased()
        }
        
        func CreateAccount(password:String) throws {
                
                let result = LibCreateAccount(password.toGoString());
                let addr = String(cString:result.r0)
                let cipher = String(cString:result.r1)
                
                if addr == ""{
                        throw ServiceError.LibCreateAccountErr
                }
                
                self.addr = addr
                self.cipher = cipher
                self.password = password
                
                try SaveAccount()
        }
        
        func SaveAccount() throws{
                let jsonbody : [String : Any] = [
                        "Address" : self.addr,
                        "PassWord" : self.password,
                        "CipherTxt" : self.cipher,
                        ]
                
                let data = try JSONSerialization.data(withJSONObject: jsonbody, options: .prettyPrinted)
                defaults.set(data, forKey: KEY_FOR_ACCOUNT_PATH)
        }
        
        func RemoveAccount(){
                self.addr = ""
                self.password = ""
                self.cipher = ""
                self.ethAddr = ""
                defaults.removeObject(forKey: KEY_FOR_ACCOUNT_PATH)
        }
        
        func ImportAccount(data: Data?, password:String) throws{
                let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:String]
                let cipher = json["CipherTxt"]!
                let addr = json["Address"]!
                
                let success = LibVerifyAccount(cipher.toGoString(), addr.toGoString(), password.toGoString()) != 0
                if !success{
                        throw ServiceError.LibAccountVerifyErr
                }
                self.addr = addr
                self.password = password
                self.cipher = cipher
                try SaveAccount()
        }
        
        func ExportAccount(url:URL?) throws{
                let jsonbody : [String : Any] = [
                        "Address" : self.addr,
                        "CipherTxt" : self.cipher,
                        ]
                let data = try JSONSerialization.data(withJSONObject: jsonbody, options: .prettyPrinted)
                try data.write(to: url!, options: .atomicWrite)
        }
}
