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
        
        public static let SubMinerPoolLoadedNoti = Notification.Name(rawValue: "SubMinerPoolLoadedNoti")
        
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
        static var lastUsedPoolAddr:String = ""
        static var lastUsedPool:MinerPool? = nil
        //TODO::
        static func PoolNameInUse() -> String? {
                
                if nil == lastUsedPool{
                        
                        guard let addr = UserDefaults.standard.string(forKey: KEY_FOR_CURRENT_POOL_INUSE) else{
                                return nil
                        }
                        
                        guard let ret = PoolDetails(addr.toGoString()) else{
                                return nil
                        }
                        
                        guard let data = String(cString:ret).data(using: .utf8) else{
                                return nil
                        }
                        
                        guard let dic = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! NSDictionary else {
                                return nil
                        }
                        lastUsedPool = MinerPool.init(dict:dic)
                }
                
                return lastUsedPool?.ShortName
        }
        
        static func SetPoolNameInUse(addr:String){
                UserDefaults.standard.set(addr, forKey: KEY_FOR_CURRENT_POOL_INUSE)
        }
        
        static public var PayChannels:[MicroPayChannel] = []
        
        static func loadMyChannels(){
                self.PayChannels.removeAll()
                guard let data = String(cString: MyChannelWithDetails()).data(using: .utf8) else{
                        return
                }
                self.parseSubPools(data:data)
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
                
                SyncChannelWithDetails(userAddress.toGoString())
        }
}
