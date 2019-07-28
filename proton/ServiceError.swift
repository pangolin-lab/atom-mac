//
//  ServiceError.swift
//  Proton
//
//  Created by Li Wansheng on 2019/4/11.
//  Copyright © 2019年 com.nbs. All rights reserved.
//

import Foundation

enum ServiceError:Error {
        case SysPorxyMountErr
        case SysProxyRemoveErr
        case SysProxySetupErr
        
        case LibStopServerErr
        case LibAccountVerifyErr
        case LibInitServerErr
        case LibCreateProxyErr
        case LibCreateAccountErr
        case LicenseNotInstall 
        
        case AccountEmpty
        
        case NoLicense
        case InvalidLicense
        case LicenseNotMatch
        
        case NetworkInvalid
        case InvalidIPSetting
        case InvalidIDSetting
        
        case AlreadyStarted
        case DiskWriteErr
        case DataParseErr
        
        case CreateEthereumAccountError
        case ImportEthereumAccountError
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
                case .LibStopServerErr:
                        return NSLocalizedString("Stop proxy server failed".localized, comment: "Stop Error")
                case .LibAccountVerifyErr:
                        return NSLocalizedString("Unlock block chain account error".localized, comment: "Unlock Error")
                case .LibInitServerErr:
                        return NSLocalizedString("Init proxy server error".localized, comment: "Start Error")
                case .LibCreateAccountErr:
                        return NSLocalizedString("Failed to create account".localized, comment: "Create Failed")
                case .AccountEmpty:
                        return NSLocalizedString("No account, please create or import one".localized, comment: "No Account")
                case .NoLicense:
                        return NSLocalizedString("No available license".localized, comment: "No License")
                case .InvalidLicense:
                        return NSLocalizedString("License is not invalid".localized, comment: "Invalid License")
                case .NetworkInvalid:
                        return NSLocalizedString("Boot strap network setting invalid".localized, comment: "Invalid Network")
                case .AlreadyStarted:
                        return NSLocalizedString("Dpulibcate start command".localized, comment: "Invalid Start")
                case .DiskWriteErr:
                        return NSLocalizedString("Save data to disk failed".localized, comment: "Save Failed")
                case .DataParseErr:
                        return NSLocalizedString("Data parse failed".localized, comment: "Invalid Data")
                case .LicenseNotMatch:
                        return NSLocalizedString("License is not for current account".localized, comment: "Invalid Licnese")
                case .LicenseNotInstall:
                        return NSLocalizedString("License installed failed".localized, comment: "Invalid Licnese")
                case .InvalidIDSetting:
                        return NSLocalizedString("Network setting ID address format error".localized, comment: "Invalid Network")
                case .InvalidIPSetting:
                        return NSLocalizedString("Network setting IP address format error".localized, comment: "Invalid Network")
                case .LibCreateProxyErr:
                        return NSLocalizedString("Create pipe proxy error".localized, comment: "Invalid Network")
                case .CreateEthereumAccountError:
                        return NSLocalizedString("Create ethereum account failed".localized, comment: "Create Failed")
                case .ImportEthereumAccountError:
                        return NSLocalizedString("Import ethereum account failed".localized, comment: "Create Failed")
                }
        }
}
