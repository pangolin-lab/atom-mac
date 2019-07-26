//
//  ethereumAccountBean.swift
//  sofa
//
//  Created by wsli on 2019/7/15.
//  Copyright © 2019 com.nbs. All rights reserved.
//

import Foundation
import DecentralizedShadowSocks

class EthereumAccount :NSObject{
        var keystoreDirect:String = ""
        var ethAddrArr:[String] = []
        var ethCiphTxt:[String:String] = [:]
      
        var queue = DispatchQueue(label: "smart contract queue")
        
        override init() {
                super.init()
                loadAccount()
        }
        
        public func IsEmpty() -> Bool{
                return self.ethAddrArr.count == 0
        }
        
        public func loadAccount(){
                let fm = FileManager.default
                do {
                        self.ethAddrArr.removeAll()
                        self.ethCiphTxt.removeAll()
                        
                        let walletDir = try Service.getEthereumWalletDir()
                        self.keystoreDirect = walletDir.path
                        let items = try fm.contentsOfDirectory(atPath: self.keystoreDirect)
                        for item in items {
                                let fp = walletDir.appendingPathComponent(item, isDirectory: false)
                                let addr = parseEthAddress(fileName: fp)
                                if addr != ""{
                                        self.ethAddrArr.append(addr)
                                }
                        }
                } catch let err {
                        print(err)
                }
        }
        //UTC--2019-07-17T12-10-38.319210000Z--52e980f172c267540f8485ca74a762fc6e44286f
        func parseEthAddress(fileName:URL) -> String{
                
                do {
                        let data = try Data(contentsOf: fileName)
                        
                        guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String : Any] else{
                               print("This is not a wallet file", fileName.absoluteString)
                               return ""
                        }
                        guard var addr = json["address"] as? String else{
                                print("No ethereum address found in this wallet file", fileName.absoluteString)
                                return ""
                        }
                        
                        addr = "0x" + addr
                        self.ethCiphTxt[addr] = String(data: data, encoding: .utf8)
                        return addr
                        
                } catch let err {
                        print(err)
                }
                
                return ""
        }
        
        public func CreateAccount(passwd:String) throws{
                guard let ret = LibCreateEthAccount(passwd.toGoString(), self.keystoreDirect.toGoString()) else{
                        throw ServiceError.CreateEthereumAccountError
                }
                
                let addr = String(cString:ret)
                if addr == ""{
                        throw ServiceError.CreateEthereumAccountError
                }
                
                loadAccount()
        }
        
        func LoadBalance(address: String) -> (Double, Double, Int){
                let ret = LibEthBindings(address.toGoString())
                return (Double(ret.r0), Double(ret.r1), Int(ret.r2))
        }
        
        func ImportAccount(path: String, password: String) throws{
                
                guard let addr = LibImportEthAccount(path.toGoString(), self.keystoreDirect.toGoString(), password.toGoString()) else{
                        throw ServiceError.ImportEthereumAccountError
                }
                
                if String(cString:addr) == "" {
                        throw ServiceError.ImportEthereumAccountError
                }
                
                loadAccount()
        }
}
