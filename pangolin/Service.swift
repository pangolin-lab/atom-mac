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
let KEY_FOR_CURRENT_POOL_INUSE    = "KEY_FOR_CURRENT_SEL_POOL"


let KEY_FOR_ACCOUNT_PATH        = "KEY_FOR_ACCOUNT_PATH"
let KEY_FOR_NETWORK_PATH        = "KEY_FOR_NETWORK_PATH"
let KEY_FOR_DATA_DIRECTORY      = ".Pangolin/data"
let CACHED_POOL_DATA_FILE       = "cachedPool.data"
let CACHED_SUB_POOL_DATA_FILE   = "subPool.data"
let KEY_FOR_WALLET_DIRECTORY    = ".pangolin/wallet"
let KEY_FOR_WALLET_FILE         = "wallet.json"


public let TOKEN_ADDRESS = "0x7001563e8f2ec996361b72f746468724e1f1276c"
public let MICROPAY_SYSTEM_ADDRESS = "0xe735093631354907a5765Cda378B7442991FE6d4"
public let BLOCKCHAIN_API_URL = "https://ropsten.infura.io/v3/8b8db3cca50a4fcf97173b7619b1c4c3"
public let BaseEtherScanUrl = "https://ropsten.etherscan.io"  //"https://ropsten.etherscan.io"//"https://etherscan.io"

struct BasicConfig{
        
        var isTurnon: Bool = false
        var isGlobal:Bool = false
        var packetPrice:Int64 = -1
        var baseDir:String = ".pangolin"
        var poolInUsed:MinerPool? = nil
        var poolAddr:String? = nil
        
        mutating func loadConf(){
                
                self.isGlobal = UserDefaults.standard.bool(forKey: KEY_FOR_Pangolin_MODEL)
                self.poolAddr = UserDefaults.standard.string(forKey: KEY_FOR_CURRENT_POOL_INUSE)
                if self.poolAddr != nil{
                        let ret = PoolDetails(self.poolAddr!.toGoString())
                        if ret != nil{
                                self.poolInUsed = MinerPool.init(json:String(cString: ret!))
                        }
                }
                
                self.packetPrice = QueryMicroPayPrice()
                
                do {
                        self.baseDir = try touchDirectory(directory: ".pangolin").path
                }catch let err{
                        print(err)
                        self.baseDir = ".pangolin"
                }
        }
        
        func save(){
                UserDefaults.standard.set(isTurnon, forKey: KEY_FOR_SWITCH_STATE)
                UserDefaults.standard.set(isGlobal, forKey: KEY_FOR_Pangolin_MODEL)
        }
        
        func lastUsedPool() ->String?{
                return self.poolInUsed?.ShortName
        }
}

class Service: NSObject {
        
        var defaults = UserDefaults.standard
        var srvConf = BasicConfig()
        
        var pacServ:PacServer = PacServer()
        
        public static let VPNStatusChanged = Notification.Name(rawValue: "VPNStatusChanged")
        
        public let contractQueue = DispatchQueue(label: "smart contract queue")
        private let serviceQueue = DispatchQueue(label: "vpn service queue")
    
        public static func getDocumentsDirectory() -> URL {
                let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                return paths[0]
        }
        
        private override init(){
                super.init()
        }
        
        class var sharedInstance: Service {
                struct Static {
                        static let instance: Service = Service()
                }
                return Static.instance
        }
        
        
        public func amountService() throws{
                
                srvConf.loadConf()
                let ret = initApp(TOKEN_ADDRESS.toGoString(),
                                  MICROPAY_SYSTEM_ADDRESS.toGoString(),
                                  BLOCKCHAIN_API_URL.toGoString(),
                                  srvConf.baseDir.toGoString())
                
                if ret.r0 != 0 {
                        throw ServiceError.SdkActionErr("init app err: no:[\(ret.r0)] msg:[\(String(cString:ret.r1))]")
                }
                
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
                
                stopService()
                self.srvConf.isTurnon = false
        }
        
        
        public func StartServer(password:String) throws{
                
                if Wallet.sharedInstance.IsEmpty(){
                        throw ServiceError.EmptyWalletErr
                }
                
                guard let poolAddr = MPCManager.PoolNameInUse() else {
                        throw ServiceError.NoPaymentChanErr
                }
    
                if !SysProxyHelper.SetupProxy(isGlocal: self.srvConf.isGlobal){
                        throw ServiceError.SysProxySetupErr
                }
                
                serviceQueue.async {
                        
                        let ret = startService("127.0.0.1:\(ProxyLocalPort)".toGoString(),
                                               password.toGoString(),
                                               poolAddr.toGoString())
                       
                        
                        self.srvConf.isTurnon = false
                        NotificationCenter.default.post(name: Service.VPNStatusChanged, object:
                                self, userInfo:["msg":String(cString: ret.r1), "errNo":ret.r0])
                }
                
                NotificationCenter.default.post(name: Service.VPNStatusChanged, object:
                        self, userInfo:nil)
                self.srvConf.isTurnon = true
        }
        
        
        public func ChangeModel(global:Bool) throws{
                
                self.srvConf.isGlobal = global
                
                if !self.srvConf.isTurnon{
                        return
                }
                
                if !SysProxyHelper.SetupProxy(isGlocal: global){
                       throw ServiceError.SysProxySetupErr
                }
        }
        
        public func Exit(){
                self.srvConf.save()
                _ = SysProxyHelper.RemoveSetting()
        }
}
