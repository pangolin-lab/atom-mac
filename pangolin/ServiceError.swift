//
//  ServiceError.swift
//  Pangolin
//
//  Created by Bencong Ri on 2019/4/11.
//  Copyright © 2019年 pangolink.org All rights reserved.
//

import Foundation

enum ServiceError:Error {
        case SysPorxyMountErr
        case SysProxyRemoveErr
        case SysProxySetupErr
        case ParseJsonErr
        case ParseWalletErr
}

extension ServiceError: LocalizedError {
        public var errorDescription: String? {
                switch self {
                case .SysPorxyMountErr:
                        return NSLocalizedString("Mount system proxy model error".localized, comment: "Mount Error")
                case .SysProxyRemoveErr:
                        return NSLocalizedString("Remove the system proxy setting error".localized, comment: "Remove Proxy Error")
                case .SysProxySetupErr:
                        return NSLocalizedString("Setup system proxy error".localized, comment: "Setup Error")
                case .ParseJsonErr:
                        return NSLocalizedString("Pasrese json data failed".localized, comment: "Parse Error")
                case .ParseWalletErr:
                        return NSLocalizedString("Pasrese wallet from json data failed".localized, comment: "Parse Error")
                }
        }
}
