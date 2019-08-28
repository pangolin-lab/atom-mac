//
//  AccountBean.swift
//  Pangolin
//
//  Created by Bencong Ri on 2019/4/11.
//  Copyright © 2019年 pangolink.org All rights reserved.
//

import Foundation
import DecentralizedShadowSocks

class MinerPool: NSObject {
        var Name:String
        var Desc:String
        override init(){
                Name = ""
                Desc = ""
                super.init()
        }
}

class Wallet:NSObject{
        
        let KEY_FOR_WALLET_DIRECTORY = ".pangolin/wallet"
        let KEY_FOR_WALLET_FILE = "wallet.json"
        var defaults = UserDefaults.standard
        var queue = DispatchQueue(label: "smart contract queue")
        
        var MainAddress:String
        var SubAddress:String
        var SMP:[MinerPool] = []
        
        override init() {
                MainAddress = ""
                SubAddress = ""
                super.init()
                loadWallet()
                let t = MinerPool()
                t.Name = "test"
                self.SMP.append(t)
        }
        
        class var sharedInstance: Wallet {
                struct Static {
                        static let instance: Wallet = Wallet()
                }
                return Static.instance
        }
        
       func loadWallet(){
                do {
                        let url = try touchDirectory(directory: KEY_FOR_WALLET_DIRECTORY)
                        let filePath = url.appendingPathComponent(KEY_FOR_WALLET_FILE, isDirectory: false)
                        if !FileManager.default.fileExists(atPath: filePath.path){
                                return
                        }
                        
                        let data = try Data(contentsOf: filePath)
                        
                        guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String : Any] else{
                                throw ServiceError.ParseJsonErr
                        }
                        
                        guard let main = json["mainAddress"] as? String else{
                                throw ServiceError.ParseWalletErr
                        }
                        
                        guard let sub = json["subAddress"] as? String else{
                                throw ServiceError.ParseWalletErr
                        }
                        
                        MainAddress = main
                        SubAddress = sub
                        
                } catch let err{
                        print(err)
                        ShowNotification(tips: err.localizedDescription)
                }
        }
        
        public func IsEmpty() -> Bool{
                return self.MainAddress == ""
        }
        
        public func CreateNewWallet(passPhrase:String) -> Bool{
                do{
                        guard let walletJson = DssNewWallet(passPhrase.toGoString()) else{
                                throw ServiceError.NewWalletErr
                        }
                        guard let data = String(cString: walletJson).data(using: .utf8) else{
                                throw ServiceError.ParseJsonErr
                        }
                        
                        let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:Any]
                        self.MainAddress = json["mainAddress"] as! String
                        self.SubAddress = json["subAddress"] as! String
                        
                        let url = try touchDirectory(directory: KEY_FOR_WALLET_DIRECTORY)
                        let filePath = url.appendingPathComponent(KEY_FOR_WALLET_FILE, isDirectory: false)
                        try data.write(to: filePath, options: .atomicWrite)
                        
                }catch let err{
                        dialogOK(question: "Error", text: err.localizedDescription)
                        return false
                }
                
                dialogOK(question: "Success", text: "Create new wallet success!")
                return true
        }
}
