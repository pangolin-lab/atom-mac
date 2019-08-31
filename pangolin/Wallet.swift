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
        
        let KEY_FOR_WALLET_DIRECTORY = ".pangolin/wallet"
        let KEY_FOR_WALLET_FILE = "wallet.json"
        var defaults = UserDefaults.standard
        
        var MainAddress:String = ""
        var SubAddress:String = ""
        var EthBalance:String = "0.00000000"
        var TokenBalance:String = "0.00000000"
        var SMP:[MinerPool] = []
        
        override init() {
                super.init()
                loadWallet()
                let t = MinerPool()
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
                                throw ServiceError.ParseJsonErr
                        }
                        
                        guard let sub = json["subAddress"] as? String else{
                                throw ServiceError.ParseJsonErr
                        }
                        
                        self.MainAddress = main
                        self.SubAddress = sub
                        
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
        
        public func syncBlockChainBalance(){
                if self.MainAddress.elementsEqual(""){
                        self.EthBalance = "0.00"
                        self.TokenBalance = "0.00"
                        return
                }
                let addr = self.MainAddress.toGoString()
                let balance = WalletBalance(addr)
                self.TokenBalance = String(cString: balance.r0)
                self.EthBalance = String(cString: balance.r1)
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
}
