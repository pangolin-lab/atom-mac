//
//  AccountBean.swift
//  Proton
//
//  Created by Bencong Rion 2019/4/11.
//  Copyright © 2019年 com.proton. All rights reserved.
//

import Foundation
import DecentralizedShadowSocks

class Wallet:NSObject{
        
        var MainAddress:String
        var SubAddress:String
        override init() {
                MainAddress = ""
                SubAddress = ""
                super.init()
        }
        
        init(main:String, sub:String){
                MainAddress = main
                SubAddress = sub
                super.init()
        }
}

class WalletManager :NSObject{
        let KEY_FOR_ETHEREUM_DIRECTORY = "pangolin/ethereumWallet"
        
        var defaults = UserDefaults.standard
        var queue = DispatchQueue(label: "smart contract queue")
        var CachedWallets:[Wallet] = []
        
        override init() {
                super.init()
                let  runer  = Thread.init(target: self, selector: #selector(loadFromFilePath), object: nil)
                runer.start()
        }
        
        class var sharedInstance: WalletManager {
                struct Static {
                        static let instance: WalletManager = WalletManager()
                }
                return Static.instance
        }
        
       @objc func loadFromFilePath(){
                self.CachedWallets.removeAll()
                do {
                        let url = try LoadFileUrl(file: KEY_FOR_ETHEREUM_DIRECTORY)
                        let items = try FileManager.default.contentsOfDirectory(atPath: url.path)
                        for item in items {
                                let fp = url.appendingPathComponent(item, isDirectory: false)
                                let wallet = try parseEthAddress(fileName: fp)
                                self.CachedWallets.append(wallet)
                        }
                } catch let err{
                        print(err)
                        ShowNotification(tips: err.localizedDescription)
                }
        }
        
        func parseEthAddress(fileName:URL) throws -> Wallet{
                
                let data = try Data(contentsOf: fileName)
                
                guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String : Any] else{
                        throw ServiceError.ParseJsonErr
                }
                
                guard let main = json["address"] as? String else{
                       throw ServiceError.ParseWalletErr
                }
                
                guard let sub = json["subAddress"] as? String else{
                        throw ServiceError.ParseWalletErr
                }
                
                return Wallet.init(main: main, sub: sub)
        }
}
