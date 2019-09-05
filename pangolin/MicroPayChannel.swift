//
//  MicroPayChannel.swift
//  Pangolin
//
//  Created by wsli on 2019/9/2.
//  Copyright © 2019 com.nbs. All rights reserved.
//

import Foundation
import DecentralizedShadowSocks


class MicroPayChannel: NSObject {
        
        var MainAddr:String = ""
        var RemindTokens:Float64 = 0.0
        var RemindPackets:Int64 = 0
        var Expiration:Int64 = 0
        
        public static let SubMinerPoolLoadedNoti = Notification.Name(rawValue: "MinerPoolChangedNoti")
        
        override init(){
                super.init()
        }
        
        init(dict:NSDictionary){
                super.init()
                
                self.MainAddr = dict["MainAddr"] as! String
                self.RemindTokens = dict["RemindTokens"] as! Float64
                self.RemindPackets = dict["RemindPackets"] as! Int64
                self.Expiration = dict["Expiration"] as! Int64
        }
}

class MPCManager:NSObject{
        static func PoolNameInUse() -> String? {
                return UserDefaults.standard.string(forKey: KEY_FOR_CURRENT_POOL_INUSE)
        }
        
        static func SetPoolNameInUse(addr:String){
                UserDefaults.standard.set(addr, forKey: KEY_FOR_CURRENT_POOL_INUSE)
        }
        
        static public var PayChannels:[MicroPayChannel] = []
        
        static func loadMyChannels(){
                let userAddress = Wallet.sharedInstance.MainAddress
                if userAddress.elementsEqual(""){
                        self.PayChannels.removeAll()
                        return
                }
                
                do{
                        let url = try touchDirectory(directory: KEY_FOR_WALLET_DIRECTORY)
                        let filePath = url.appendingPathComponent(CACHED_SUB_POOL_DATA_FILE, isDirectory: false)
                        if !FileManager.default.fileExists(atPath: filePath.path){
                                loadMyPoolsFromBlockChain()
                                return
                        }
                        
                        let data = try Data(contentsOf: filePath)
                        self.parseSubPools(data:data)
                        self.loadMyPoolsFromBlockChain()
                        
                } catch let err{
                        print(err)
                        dialogOK(question: "Error", text: err.localizedDescription)
                }
        }
        
        static func parseSubPools(data:Data) -> Void {
                guard let array = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! NSArray else {
                        return
                }
                
                self.PayChannels.removeAll()
                
                for (_, value) in array.enumerated() {
                        
                        guard let dict = value as? NSDictionary else{
                                continue
                        }
                        
                        let channel = MicroPayChannel.init(dict:dict)
                        self.PayChannels.append(channel)
                }
                
        }
        
        static  func loadMyPoolsFromBlockChain(){
                let userAddress = Wallet.sharedInstance.MainAddress
                if userAddress.elementsEqual(""){
                        return
                }
        
         Service.sharedInstance.queue.async {
                
                do{
                        guard let subPools = MyChannelWithDetails(userAddress.toGoString()) else{
                                return
                        }
                        let jsonStr = String(cString: subPools)
                        let jsonData:Data = jsonStr.data(using: .utf8)!
                        if jsonData.count == 0{
                                return
                        }

                        self.parseSubPools(data: jsonData)

                        let url = try touchDirectory(directory: KEY_FOR_DATA_DIRECTORY)
                        let filePath = url.appendingPathComponent(CACHED_SUB_POOL_DATA_FILE, isDirectory: false)
                        try jsonData.write(to: filePath)
                        
                        NotificationCenter.default.post(name: MicroPayChannel.SubMinerPoolLoadedNoti, object:
                                self, userInfo:["success":true])

                } catch let err{
                        print(err)
                        NotificationCenter.default.post(name: MicroPayChannel.SubMinerPoolLoadedNoti, object:
                                self, userInfo:["success":false, "msg":err.localizedDescription])
                }
        }
        }
}
