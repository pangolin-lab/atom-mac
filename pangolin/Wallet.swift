//
//  AccountBean.swift
//  Pangolin
//
//  Created by Bencong Ri on 2019/4/11.
//  Copyright © 2019年 pangolink.org All rights reserved.
//

import Foundation
import DecentralizedShadowSocks

class Wallet:NSObject{
        let BALANCE_TOKEN_KEY = "BALANCE_TOKEN_KEY"
        let BALANCE_ETH_KEY = "BALANCE_ETH_KEY"
        public static let WalletBalanceChangedNoti = Notification.Name(rawValue: "WalletBalanceChangedNotification")
        public static let WalletBuyPacketResultNoti = Notification.Name(rawValue: "WalletBuyPacketResultNoti")
        
        var defaults = UserDefaults.standard
        var MainAddress:String = ""
        var SubAddress:String = ""
        private var ciphereTxt = ""
        var EthBalance:Double = 0.0
        var TokenBalance:Double = 0.0
        
        override init() {
                super.init()
                loadWallet()
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
                                throw ServiceError.ParseJsonErr
                        }
                        
                        guard let sub = json["subAddress"] as? String else{
                                throw ServiceError.ParseJsonErr
                        }
                        
                        self.MainAddress = main
                        self.SubAddress = sub
                        self.ciphereTxt = String.init(bytes: data, encoding: .utf8)! 
                        
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
                        guard let walletJson = NewWallet(passPhrase.toGoString()) else{
                                throw ServiceError.NewWalletErr
                        }
                        
                        guard let data = String(cString: walletJson).data(using: .utf8) else{
                                throw ServiceError.ParseJsonErr
                        }
                        
                        try syncWalletData(data: data)
                }catch let err{
                        dialogOK(question: "Error", text: err.localizedDescription)
                        return false
                }
                
                dialogOK(question: "Success", text: "Create new wallet success!")
                return true
        }
        
        func syncWalletData(data:Data) throws {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:Any]
                self.MainAddress = json["mainAddress"] as! String
                self.SubAddress = json["subAddress"] as! String
                
                let url = try touchDirectory(directory: KEY_FOR_WALLET_DIRECTORY)
                let filePath = url.appendingPathComponent(KEY_FOR_WALLET_FILE, isDirectory: false)
                try data.write(to: filePath, options: .atomicWrite)
        }
        
        
        public func syncTokenBalance(){
                if self.MainAddress.elementsEqual(""){
                        self.EthBalance = 0.0
                        self.TokenBalance = 0.0
                        return
                }
                
                
                self.TokenBalance = UserDefaults.standard.double(forKey: BALANCE_TOKEN_KEY)
                self.EthBalance = UserDefaults.standard.double(forKey: BALANCE_ETH_KEY)
                
                self.loadBalanceFromBlockChain()
        }
        
        func loadBalanceFromBlockChain(){
                
                Service.sharedInstance.queue.async() {
                        let addr = self.MainAddress.toGoString()
                        let balance = WalletBalance(addr)
                        self.TokenBalance = balance.r0
                        self.EthBalance = balance.r1
                        UserDefaults.standard.set(self.TokenBalance, forKey: self.BALANCE_TOKEN_KEY)
                        UserDefaults.standard.set(self.EthBalance, forKey: self.BALANCE_ETH_KEY)
                        
                        NotificationCenter.default.post(name: Wallet.WalletBalanceChangedNoti, object:
                                self, userInfo:nil)
                }
        }
        
        func ExportWallet(dst:URL?) throws{
                let source = try touchDirectory(directory: KEY_FOR_WALLET_DIRECTORY)
                let filePath = source.appendingPathComponent(KEY_FOR_WALLET_FILE, isDirectory: false)
                if !FileManager.default.fileExists(atPath: filePath.path){
                        throw ServiceError.NewWalletErr
                }
                
                let data = try Data(contentsOf: filePath)
                try data.write(to: dst!, options: .atomicWrite)
        }
        
        func ImportWallet(json: String, password:String) throws{
                guard WalletVerify(json.toGoString(), password.toGoString()) != 0 else {
                        throw ServiceError.InvalidWalletErr
                }
                try syncWalletData(data: json.data(using: .utf8)!)
        }
        
        func BuyPacketFrom(pool:String, for user:String, by coin:Double, with password:String){
                
                Service.sharedInstance.queue.async {
                        
                        let ret = BuyPacket(user.toGoString(),
                                  pool.toGoString(),
                                  password.toGoString(),
                                  self.ciphereTxt.toGoString(),
                                  coin)
                        let tx = String(cString: ret.r0)
                        let err = String(cString: ret.r0)
                        
                        if err != ""{
                                NotificationCenter.default.post(name: Wallet.WalletBalanceChangedNoti, object:
                                        self, userInfo:["success":false, "msg": err])
                        }else{
                                NotificationCenter.default.post(name: Wallet.WalletBalanceChangedNoti, object:
                                        self, userInfo:["success":true, "msg": tx])
                        }
                }
        }
}
