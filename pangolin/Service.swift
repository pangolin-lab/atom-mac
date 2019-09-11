//
//  Service.swift
//  Pangolin
//
//  Created by Bencong Ri on 2019/4/11.
//  Copyright © 2019年 pangolink.org All rights reserved.
//

import Foundation
import DecentralizedShadowSocks

let KEY_FOR_SWITCH_STATE        = "KEY_FOR_SWITCH_STATE"
let KEY_FOR_Pangolin_MODEL      = "KEY_FOR_Pangolin_MODEL"
let KEY_FOR_ACCOUNT_PATH        = "KEY_FOR_ACCOUNT_PATH"
let KEY_FOR_NETWORK_PATH        = "KEY_FOR_NETWORK_PATH"
let KEY_FOR_CURRENT_POOL_INUSE    = "KEY_FOR_CURRENT_SEL_POOL"
let KEY_FOR_BOOTSTRAP_PATH      = ".Pangolin/PangolinBootNodes.dat"
let KEY_FOR_DATA_DIRECTORY      = ".Pangolin/data"
let CACHED_POOL_DATA_FILE       = "cachedPool.data"
let CACHED_SUB_POOL_DATA_FILE   = "subPool.data"
let KEY_FOR_WALLET_DIRECTORY    = ".pangolin/wallet"
let KEY_FOR_WALLET_FILE         = "wallet.json"

//let NET_WORK_SETTING_URL="https://raw.githubusercontent.com/pangolin-lab/quantum/master/seed_debug.quantum"
public let NET_WORK_SETTING_URL="https://raw.githubusercontent.com/pangolin-lab/quantum/master/seed.quantum"

public let TOKEN_ADDRESS = "0x7001563e8f2ec996361b72f746468724e1f1276c"
public let MICROPAY_SYSTEM_ADDRESS = "0x7224DA8C217d9520Ae4b2EEFFD05414B6e00bEe3"
public let BLOCKCHAIN_API_URL = "https://ropsten.infura.io/v3/8b8db3cca50a4fcf97173b7619b1c4c3"
//public let BaseEtherScanUrl = "https://ropsten.etherscan.io"//"https://etherscan.io"
public let BaseEtherScanUrl = "https://ropsten.etherscan.io"

class Service: NSObject {
        
        var defaults = UserDefaults.standard
        var IsTurnOn:Bool = false
        var IsGlobal:Bool = false 
        var SystemPacketPrice:Int64 = -1
        var pacServ:PacServer = PacServer()
        
        public static let VPNStatusChanged = Notification.Name(rawValue: "VPNStatusChanged")
        
        public let queue = DispatchQueue(label: "smart contract queue")
        private let serviceQueue = DispatchQueue(label: "vpn service queue")
    
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
        
        
        private override init(){
                super.init()
                self.IsGlobal = defaults.bool(forKey: KEY_FOR_Pangolin_MODEL)
                InitBlockChain(TOKEN_ADDRESS.toGoString(), MICROPAY_SYSTEM_ADDRESS.toGoString(), BLOCKCHAIN_API_URL.toGoString())
                self.SystemPacketPrice = QueryMicroPayPrice() 
        }
        
        class var sharedInstance: Service {
                struct Static {
                        static let instance: Service = Service()
                }
                return Static.instance
        }
        
        
        public func amountService() throws{ 
                
                let _ = Wallet.sharedInstance
                
                MPCManager.loadMyChannels()
                
                try  ensureLaunchAgentsDirOwner()
                if !SysProxyHelper.install(){
                        throw ServiceError.SysPorxyMountErr
                }
                
                try pacServ.startPACServer()
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
        }
        
        public func StartServer(password:String) throws{
                
                if Wallet.sharedInstance.IsEmpty(){
                        throw ServiceError.EmptyWalletErr
                }
                
                guard let poolAddr = MPCManager.PoolNameInUse() else {
                        throw ServiceError.NoPaymentChanErr
                }
    
                if !SysProxyHelper.SetupProxy(isGlocal: IsGlobal){
                        throw ServiceError.SysProxySetupErr
                }
                
                serviceQueue.async {
                        
                        let cipher = Wallet.sharedInstance.ciphereTxt.toGoString()
                        
                        let ret = RunVpnService(password.toGoString(),
                                         cipher,
                                         poolAddr.toGoString(),
                                         "127.0.0.1:\(ProxyLocalPort)".toGoString())
                        
                        self.IsTurnOn = false
                        NotificationCenter.default.post(name: Service.VPNStatusChanged, object:
                                self, userInfo:["msg":String(cString: ret!)])
                }
                
                NotificationCenter.default.post(name: Service.VPNStatusChanged, object:
                        self, userInfo:nil)
                self.IsTurnOn = true
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
        
        public func Exit(){
                defaults.set(IsTurnOn, forKey: KEY_FOR_SWITCH_STATE)
                defaults.set(IsGlobal, forKey: KEY_FOR_Pangolin_MODEL)
                _ = SysProxyHelper.RemoveSetting()
        }
}
