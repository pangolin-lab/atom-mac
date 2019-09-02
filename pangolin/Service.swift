//
//  Service.swift
//  Pangolin
//
//  Created by Bencong Ri on 2019/4/11.
//  Copyright © 2019年 pangolink.org All rights reserved.
//

import Foundation
import DecentralizedShadowSocks

let KEY_FOR_SWITCH_STATE = "KEY_FOR_SWITCH_STATE"
let KEY_FOR_Pangolin_MODEL = "KEY_FOR_Pangolin_MODEL"
let KEY_FOR_ACCOUNT_PATH = "KEY_FOR_ACCOUNT_PATH"
let KEY_FOR_NETWORK_PATH = "KEY_FOR_NETWORK_PATH"
let KEY_FOR_BOOTSTRAP_PATH = ".Pangolin/PangolinBootNodes.dat"
let KEY_FOR_ETHEREUM_DIRECTORY = ".Pangolin/ethereumWallet"
let KEY_FOR_DATA_DIRECTORY = ".Pangolin/data"
let CACHED_POOL_DATA_FILE = "cachedPool.data"
//let NET_WORK_SETTING_URL="https://raw.githubusercontent.com/pangolin-lab/quantum/master/seed_debug.quantum"
let NET_WORK_SETTING_URL="https://raw.githubusercontent.com/pangolin-lab/quantum/master/seed.quantum"

let TOKEN_ADDRESS = "0x7001563e8f2ec996361b72f746468724e1f1276c"
let MICROPAY_SYSTEM_ADDRESS = "0xC8e1DbBE3cBF06a145234a4723076EED7b4AF59c"
let BLOCKCHAIN_API_URL = "https://ropsten.infura.io/v3/8b8db3cca50a4fcf97173b7619b1c4c3"
//public let BaseEtherScanUrl = "https://ropsten.etherscan.io"//"https://etherscan.io"

class Service: NSObject {
        
        var defaults = UserDefaults.standard
        var IsTurnOn:Bool = false
        var IsGlobal:Bool = false 
       
        var pacServ:PacServer = PacServer()
        var uiDelegate:StateChangedDelegate? = nil
        public var queue = DispatchQueue(label: "smart contract queue")
    
    
        public static func getDocumentsDirectory() -> URL {
                let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                return paths[0]
        }
        
        public static func getBootNode() -> URL {
                let url = getDocumentsDirectory().appendingPathComponent(KEY_FOR_BOOTSTRAP_PATH)
                if !FileManager.default.fileExists(atPath: url.path){
                        FileManager.default.createFile(atPath: url.path, contents: nil, attributes: nil)
                }
                return url
        }
        
        public static func getEthereumWalletDir() throws -> URL {
                let url = getDocumentsDirectory().appendingPathComponent(KEY_FOR_ETHEREUM_DIRECTORY)
                
                if !FileManager.default.fileExists(atPath: url.path){
                        try FileManager.default.createDirectory(at:url, withIntermediateDirectories: true, attributes: nil)
                }
                return url
        }
        
        private override init(){
                super.init()
                self.IsGlobal = defaults.bool(forKey: KEY_FOR_Pangolin_MODEL)
//                InitBlockChain(TOKEN_ADDRESS.toGoString(), MICROPAY_SYSTEM_ADDRESS.toGoString(), BLOCKCHAIN_API_URL.toGoString())
        }
        
        class var sharedInstance: Service {
                struct Static {
                        static let instance: Service = Service()
                }
                return Static.instance
        }
        
        public func SetDelegate(d:StateChangedDelegate){
                self.uiDelegate = d
        }
        
        
        public func amountService() throws{
                
                try  ensureLaunchAgentsDirOwner()
                if !SysProxyHelper.install(){
                        throw ServiceError.SysPorxyMountErr
                }
                
                try pacServ.startPACServer()
                
                if !IsTurnOn{
                        return
                }
                
                if !SysProxyHelper.SetupProxy(isGlocal: IsGlobal){
                        throw ServiceError.SysProxySetupErr
                }
                
                try StartServer()
        }
        
        public func StopServer() throws{
                
                if !SysProxyHelper.RemoveSetting(){
                        throw ServiceError.SysProxyRemoveErr
                }
                
                LibStopClient()
                IsTurnOn = false
        }
        
        @objc func clinetRunning(){
                print("---client is started---")
                LibProxyRun()
                print("---client is closed---")
                self.IsTurnOn = false
                let _ = SysProxyHelper.RemoveSetting()
                self.uiDelegate?.updateMenu(data: nil, tagId: 4)
        }
        
        public func StartServer() throws{
    
                if !SysProxyHelper.SetupProxy(isGlocal: IsGlobal){
                        throw ServiceError.SysProxySetupErr
                }
                let  runer  = Thread.init(target: self, selector: #selector(clinetRunning), object: nil)
                runer.start()
                
                IsTurnOn = true
        }
        
        
        public func ChangeModel(global:Bool) throws{
                
                IsGlobal = global
                
                if !IsTurnOn{
                        return
                }
                
                if !SysProxyHelper.SetupProxy(isGlocal: global){
                       throw ServiceError.SysProxySetupErr
                }
        }
        
        public func RemoveAccount()throws{
                if IsTurnOn{
                        try StopServer()
                }
        }
        
        public func Exit(){
                defaults.set(IsTurnOn, forKey: KEY_FOR_SWITCH_STATE)
                defaults.set(IsGlobal, forKey: KEY_FOR_Pangolin_MODEL)
                _ = SysProxyHelper.RemoveSetting()
        }
}
