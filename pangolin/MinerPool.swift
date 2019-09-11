//
//  PacketPool.swift
//  Pangolin
//
//  Created by bencong ri on 2019/8/29.
//  Copyright © 2019年 pangolink.org All rights reserved.
//

import Foundation
import DecentralizedShadowSocks

class MinerPool: NSObject {
        var MainAddr:String = ""
        var Payer:String = ""
        var GuaranteedNo:Float64 = 0.0
        var ShortName:String = ""
        var DetailInfos:String = ""
        var Seeds:String = ""
        
        public static let MinerPoolChangedNoti = Notification.Name(rawValue: "MinerPoolChangedNoti")
        
        override init(){
                super.init()
        }
        
        init(dict:NSDictionary){
                self.MainAddr = dict["MainAddr"] as? String ?? ""
                self.Payer = dict["Payer"] as? String ?? ""
                self.GuaranteedNo = dict["GuaranteedNo"] as? Float64 ?? 0.00
                self.ShortName = dict["ShortName"] as? String ?? ""
                self.DetailInfos = dict["DetailInfos"] as? String ?? ""
                self.Seeds = dict["Seeds"] as? String ?? ""
        }
}

class MinerPoolManager: NSObject {
        
        static public var PoolDataCache:[String:MinerPool] = [:]
        static public var PoolAddressArr:[String] = []
        
        override init(){
                super.init()
        }
        
        static func loadMinerPool(){
                do{
                        let url = try touchDirectory(directory: KEY_FOR_DATA_DIRECTORY)
                        let filePath = url.appendingPathComponent(CACHED_POOL_DATA_FILE, isDirectory: false)
                        if !FileManager.default.fileExists(atPath: filePath.path){
                                self.loadFromBlockChain()
                                return
                        }
                        
                        let jsonData = try Data(contentsOf: filePath)
                        self.parseData(data: jsonData)
                        self.loadFromBlockChain()
                        
                } catch let err{
                        print(err)
                        dialogOK(question: "Error", text: err.localizedDescription)
                }
        }
        
        static func loadFromBlockChain(){
                
                Service.sharedInstance.queue.async {
                        do{
                                guard let poolJson = PoolListWithDetails() else { return  }
                                let str = String(cString:poolJson)
                                let jsonData:Data = str.data(using: .utf8)!
                                if jsonData.count == 0{
                                        return
                                }
                                self.parseData(data: jsonData)
                                
                                let url = try touchDirectory(directory: KEY_FOR_DATA_DIRECTORY)
                                let filePath = url.appendingPathComponent(CACHED_POOL_DATA_FILE, isDirectory: false)
                                try jsonData.write(to: filePath)
                                
                                NotificationCenter.default.post(name: MinerPool.MinerPoolChangedNoti, object:
                                        self, userInfo:["success":true])
                                
                        } catch let err{
                                print(err)
                                NotificationCenter.default.post(name: MinerPool.MinerPoolChangedNoti, object:
                                        self, userInfo:["success":false, "msg":err.localizedDescription])
                        }
                        
                }
        }
        
        static func parseData(data:Data){
                
                guard let array = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! NSArray else {
                        return
                }
                
                self.PoolDataCache.removeAll()
                for (_, value) in array.enumerated() {
                        guard let dict = value as? NSDictionary else{
                                continue
                        }
                        let pool = MinerPool.init(dict:dict)
                        MinerPoolManager.PoolDataCache[pool.MainAddr] = pool
                }
                
                self.PoolAddressArr = Array(self.PoolDataCache.keys)
        }
}
