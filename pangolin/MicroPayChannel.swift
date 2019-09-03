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
        var PayerAddr:String = ""
        var RemindTokens:Float64 = 0.0
        var RemindPackets:Int64 = 0
        var Expiration:Int64 = 0
        
        override init(){
                super.init()
        }
        
        init(dict:NSDictionary){
                super.init()
                
                self.MainAddr = dict["MainAddr"] as! String
                self.PayerAddr = dict["PayerAddr"] as! String
                self.RemindTokens = dict["RemindTokens"] as! Float64
                self.RemindPackets = dict["RemindPackets"] as! Int64
                self.Expiration = dict["Expiration"] as! Int64
        }
}

class MicroPayChannelManager:NSObject{
        
        static public var SubMinerPools:[MicroPayChannel] = []
        
        static func loadMyPools(userAddress:String){
                
                if userAddress.elementsEqual(""){
                        self.SubMinerPools.removeAll()
                        return
                }
                
                do{
                        let url = try touchDirectory(directory: KEY_FOR_WALLET_DIRECTORY)
                        let filePath = url.appendingPathComponent(CACHED_SUB_POOL_DATA_FILE, isDirectory: false)
                        if !FileManager.default.fileExists(atPath: filePath.path){
                                loadMyPoolsFromBlockChain(userAddress:userAddress)
                                return
                        }
                        
                        let data = try Data(contentsOf: filePath)
                        self.parseSubPools(data:data)
                        
                        Service.sharedInstance.queue.async() {
                                self.loadMyPoolsFromBlockChain(userAddress:userAddress)
                        }
                        
                } catch let err{
                        print(err)
                        ShowNotification(tips: err.localizedDescription)
                }
        }
        
        static func parseSubPools(data:Data) -> Void {
                guard let array = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! NSArray else {
                        return
                }
                
                self.SubMinerPools.removeAll()
                
                for (_, value) in array.enumerated() {
                        
                        guard let dict = value as? NSDictionary else{
                                continue
                        }
                        
                        let channel = MicroPayChannel.init(dict:dict)
                        self.SubMinerPools.append(channel)
                }
                
        }
        
       static  func loadMyPoolsFromBlockChain(userAddress:String){
                do{
                        guard let subPools = MySubPoolsWithDetails(userAddress.toGoString()) else{
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
                        
                } catch let err{
                        print(err)
                        ShowNotification(tips: err.localizedDescription)
                }
        }
}
