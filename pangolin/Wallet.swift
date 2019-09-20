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
        
        var defaults = UserDefaults.standard
        var MainAddress:String = ""
        var SubAddress:String = ""
        var ciphereTxt = ""
        var EthBalance:Double = 0.0
        var TokenBalance:Double = 0.0
        
        override init() {
                super.init()
                syncTokenBalance()
        }
        
        class var sharedInstance: Wallet {
                struct Static {
                        static let instance: Wallet = Wallet()
                }
                return Static.instance
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
                self.ciphereTxt = String.init(bytes: data, encoding: .utf8)!
                
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
                                
                Service.sharedInstance.contractQueue.async() {
                        let addr = self.MainAddress.toGoString()
                        let balance = WalletBalance(addr)
                        self.TokenBalance = balance.r0
                        self.EthBalance = balance.r1
                        UserDefaults.standard.set(self.TokenBalance, forKey: self.BALANCE_TOKEN_KEY)
                        UserDefaults.standard.set(self.EthBalance, forKey: self.BALANCE_ETH_KEY)
                        
                        NotificationCenter.default.post(name: WalletBalanceChangedNoti, object:
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
                
                Service.sharedInstance.contractQueue.async {
                        
                        let ret = BuyPacket(user.toGoString(),
                                  pool.toGoString(),
                                  password.toGoString(),
                                  self.ciphereTxt.toGoString(),
                                  coin)
                        ProcessTransRet(tx: String(cString: ret.r0),
                                             err: String(cString: ret.r1),
                                             noti: WalletBuyPacketResultNoti)
                }
        }
        
        func EthTransfer(password:String, target:String, no:Double){
                Service.sharedInstance.contractQueue.async {
                         Swift.print(self.ciphereTxt)
                        let ret = TransferEth(self.ciphereTxt.toGoString(), password.toGoString(), target.toGoString(), no)
                        ProcessTransRet(tx: String(cString: ret.r0),
                                             err: String(cString: ret.r1),
                                             noti: WalletTokenTransferResultNoti)
                }
        }
        
        func LinTokenTransfer(password:String, target:String, no:Double){
                Service.sharedInstance.contractQueue.async {
                        Swift.print(self.ciphereTxt)
                        let ret = TransferLinToken(self.ciphereTxt.toGoString(), password.toGoString(), target.toGoString(), no)
                        ProcessTransRet(tx: String(cString: ret.r0),
                                             err: String(cString: ret.r1),
                                             noti: WalletTokenTransferResultNoti)
                }
        }
}
