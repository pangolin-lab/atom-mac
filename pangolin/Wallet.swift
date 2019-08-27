//
//  AccountBean.swift
//  Proton
//
//  Created by Bencong Rion 2019/4/11.
//  Copyright © 2019年 com.proton. All rights reserved.
//

import Foundation
import DecentralizedShadowSocks

class Wallet :NSObject{
        
        var defaults = UserDefaults.standard
        var queue = DispatchQueue(label: "smart contract queue")
        override init() {
                super.init()
        }
}
