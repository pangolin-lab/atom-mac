//
//  Service.swift
//  Proton
//
//  Created by ribencongon 2019/4/11.
//  Copyright © 2019年 com.proton. All rights reserved.
//

import Foundation
import DecentralizedShadowSocks

let KEY_FOR_SWITCH_STATE = "KEY_FOR_SWITCH_STATE"
let KEY_FOR_PROTON_MODEL = "KEY_FOR_PROTON_MODEL"
let KEY_FOR_ACCOUNT_PATH = "KEY_FOR_ACCOUNT_PATH"
let KEY_FOR_NETWORK_PATH = "KEY_FOR_NETWORK_PATH"
let KEY_FOR_BOOTSTRAP_PATH = ".proton/protonBootNodes.dat"
let KEY_FOR_ETHEREUM_DIRECTORY = ".proton/ethereumWallet"

//let NET_WORK_SETTING_URL="https://raw.githubusercontent.com/proton-lab/quantum/master/seed_debug.quantum"
let NET_WORK_SETTING_URL="https://raw.githubusercontent.com/proton-lab/quantum/master/seed.quantum"

class Service: NSObject {
        
        var defaults = UserDefaults.standard
        var localServer = ""
        var remoteServer = "155.138.201.205:52018"
        var initilized:Bool = false
        var IsTurnOn:Bool = false
        var IsGlobal:Bool = false
        
        var account:Account = Account()
        var ethereum:EthereumAccount = EthereumAccount()
        var pacServ:PacServer = PacServer()
        var uiDelegate:StateChangedDelegate? = nil
    
    
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
//                self.IsTurnOn = defaults.bool(forKey: KEY_FOR_SWITCH_STATE)
                self.IsGlobal = defaults.bool(forKey: KEY_FOR_PROTON_MODEL)
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
        
        public func CheckService() throws{
                if account.IsEmpty(){
                        throw ServiceError.AccountEmpty
                }
        }
        
        public func amountService() throws{
                
                try  ensureLaunchAgentsDirOwner()
                if !SysProxyHelper.install(){
                        throw ServiceError.SysPorxyMountErr
                }
                
                if account.IsEmpty(){
                        IsGlobal = false
                        IsTurnOn = false
                        
                        if !SysProxyHelper.RemoveSetting(){
                                throw ServiceError.SysProxyRemoveErr
                        }
                        return
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
        
        public func initProxy() throws{
                try CheckService()
                let bootPath = Service.getBootNode()
                let bootNodes = try String(contentsOf: bootPath, encoding: .utf8)
                
                let ret = LibInitProxy(account.addr.toGoString(),
                                account.cipher.toGoString(),
                                NET_WORK_SETTING_URL.toGoString(),
                                bootNodes.toGoString(),
                                bootPath.relativePath.toGoString())
                
                if ret == 0 {
                        throw ServiceError.LibInitServerErr
                }
        }
        
        public func setupProxy() throws{
                let locSer = String(format: "127.0.0.1:%d", ProxyLocalPort)
                let ret = LibCreateProxy(account.password.toGoString(),locSer.toGoString())
                if ret == 0 {
                        throw ServiceError.LibCreateProxyErr
                }
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
                
                if LibIsInit() == 0{
                        try self.initProxy()
                }
                try self.setupProxy()
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
                account.RemoveAccount()
                if IsTurnOn{
                        try StopServer()
                }
        }
        
        public func Exit(){
                defaults.set(IsTurnOn, forKey: KEY_FOR_SWITCH_STATE)
                defaults.set(IsGlobal, forKey: KEY_FOR_PROTON_MODEL)
                _ = SysProxyHelper.RemoveSetting()
        }
        
        public func CreateNewAccount(password:String) throws {
                try account.CreateAccount(password: password)
        }
        
        public func CreateEthereumAccount(password:String) throws {
                try ethereum.CreateAccount(passwd: password)
        }
        
        public func ImportAccount(path:String, password:String) throws {
                let d = FileManager.default.contents(atPath: path)
                try account.ImportAccount(data: d, password: password)
        }
        
        public func ImportEthereumAccount(path:String, password:String) throws {
                
                try ethereum.ImportAccount(path: path, password: password)
        }
}
