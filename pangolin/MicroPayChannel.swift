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
        var RemindPackets:Double = 0
        var Expiration:Double = 0
        
        override init(){
                super.init()
        }
        
        init(dict:NSDictionary){
                super.init()
                self.MainAddr = dict["MainAddr"] as! String
                self.RemindPackets = dict["RemindPackets"] as! Double
                self.Expiration = dict["Expiration"] as! Double
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
        
        static public var PayChannels:[String:MicroPayChannel] = [:]
        static public func ObjAt(idx:Int) ->MicroPayChannel{
                return Array(PayChannels.values)[idx]
        }
        
        static func loadMyChannels(){
                self.PayChannels.removeAll()
                guard let ret = LoadMyChannels() else {
                        return
                }
                guard let data = String(cString: ret).data(using: .utf8) else{
                        return
                }
                self.parseSubPools(data:data)
        }
        
        static func parseSubPools(data:Data) -> Void {
                guard let chanMap = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! NSDictionary else {
                        return
                }
                
                self.PayChannels.removeAll()
                
                for (_, value) in chanMap.allValues.enumerated() {
                        
                        guard let dict = value as? NSDictionary else{
                                continue
                        }
                        
                        let channel = MicroPayChannel.init(dict:dict)
                        self.PayChannels[channel.MainAddr] = channel
                }
        }
        
        static  func loadMyPoolsFromBlockChain(){
                let userAddress = Wallet.sharedInstance.MainAddress
                if userAddress.elementsEqual(""){
                        return
                }
                
                SyncMyChannels(userAddress.toGoString())
        }
}
