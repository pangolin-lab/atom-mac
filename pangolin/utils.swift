//
//  utils.swift
//  Pangolin
//
//  Created by Bencong Ri on 2019/2/20.
//  Copyright © 2019年 pangolink.org All rights reserved.
//

import Foundation
import DecentralizedShadowSocks
import CommonCrypto

public let BaseEtherScanUrl = "https://ropsten.etherscan.io"//"https://etherscan.io"
public let KEY_FOR_DATA_DIRECTORY = ".pangolin/data"

extension String {
        var localized: String {
                return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
        }
        func format(parameters: CVarArg...) -> String {
                return String(format: self, arguments: parameters)
        }
        
        func toGoString() ->GoString {
                let cs = (self as NSString).utf8String
                let buffer = UnsafePointer<Int8>(cs!)
                return GoString(p:buffer, n:strlen(buffer))
        }
        
        func md5() -> String {
                let str = self.cString(using: String.Encoding.utf8)
                let strLen = CUnsignedInt(self.lengthOfBytes(using: String.Encoding.utf8))
                let digestLen = Int(CC_MD5_DIGEST_LENGTH)
                let result = UnsafeMutablePointer<UInt8>.allocate(capacity: 16)
                CC_MD5(str!, strLen, result)
                let hash = NSMutableString()
                for i in 0 ..< digestLen {
                        hash.appendFormat("%02x", result[i])
                }
                free(result)
                return String(format: hash as String)
        }
}

extension NSTextView {
        override open func performKeyEquivalent(with event: NSEvent) -> Bool {
                let commandKey = NSEvent.ModifierFlags.command.rawValue
                let commandShiftKey = NSEvent.ModifierFlags.command.rawValue | NSEvent.ModifierFlags.shift.rawValue
                if event.type == NSEvent.EventType.keyDown {
                        if (event.modifierFlags.rawValue & NSEvent.ModifierFlags.deviceIndependentFlagsMask.rawValue) == commandKey {
                                switch event.charactersIgnoringModifiers! {
                                case "x":
                                        if NSApp.sendAction(#selector(NSText.cut(_:)), to:nil, from:self) { return true }
                                case "c":
                                        if NSApp.sendAction(#selector(NSText.copy(_:)), to:nil, from:self) { return true }
                                case "v":
                                        if NSApp.sendAction(#selector(NSText.paste(_:)), to:nil, from:self) { return true }
                                case "z":
                                        if NSApp.sendAction(Selector(("undo:")), to:nil, from:self) { return true }
                                case "a":
                                        if NSApp.sendAction(#selector(NSResponder.selectAll(_:)), to:nil, from:self) { return true }
                                default:
                                        break
                                }
                        } else if (event.modifierFlags.rawValue & NSEvent.ModifierFlags.deviceIndependentFlagsMask.rawValue) == commandShiftKey {
                                if event.charactersIgnoringModifiers == "Z" {
                                        if NSApp.sendAction(Selector(("redo:")), to:nil, from:self) { return true }
                                }
                        }
                }
                return super.performKeyEquivalent(with: event)
        }
}

func ShowNotification(tips:String) -> Void {
        let notification = NSUserNotification()
        notification.title = tips.localized
        NSUserNotificationCenter.default
                .deliver(notification)
}

func ensureLaunchAgentsDirOwner () throws{
        let dirPath = NSHomeDirectory() + "/Library/LaunchAgents"
        let fileMgr = FileManager.default
        if !fileMgr.fileExists(atPath: dirPath) {
            exit(-1)
        }
        
        let attrs = try fileMgr.attributesOfItem(atPath: dirPath)
        if attrs[FileAttributeKey.ownerAccountName] as! String != NSUserName() {
                let bashFilePath = Bundle.main.path(forResource: "fix_dir_owner.sh", ofType: nil)!
                let script = "do shell script \"bash \\\"\(bashFilePath)\\\" \(NSUserName()) \" with administrator privileges"
                if let appleScript = NSAppleScript(source: script) {
                        var err: NSDictionary? = nil
                        appleScript.executeAndReturnError(&err)
                }
        }
}

func dialogOK(question: String, text: String) -> Void {
        let alert = NSAlert()
        alert.messageText = question.localized
        alert.informativeText = text.localized
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK".localized)
        alert.runModal()
}

func dialogOKCancel(question: String, text: String) -> Bool {
        let alert = NSAlert()
        alert.messageText = question.localized
        alert.informativeText = text.localized
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK".localized)
        alert.addButton(withTitle: "Cancel".localized)
        return alert.runModal() == .alertFirstButtonReturn
}

func accountTipsDialog() -> NSApplication.ModalResponse {
        let alert = NSAlert()
        alert.messageText = "Account empty".localized
        alert.informativeText = "Can't find any block chain account on this device, please create or import an account first".localized
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Cancel".localized)
        alert.addButton(withTitle: "Import".localized)
        alert.addButton(withTitle: "Create".localized)
        return alert.runModal()
}

func showPasswordDialog() -> String {
        let alert = NSAlert()
        alert.messageText = "Account Password".localized
        alert.informativeText = "Please input the password of this account".localized
        alert.alertStyle = .informational
        let input = NSSecureTextField.init(frame: NSRect.init(x: 0, y: 0, width: 200, height: 24))
        alert.accessoryView = input
        alert.addButton(withTitle: "OK".localized)
        alert.addButton(withTitle: "Cancel".localized)
        let butSel = alert.runModal()
        if butSel == .alertFirstButtonReturn{
                return input.stringValue
        }
        return ""
}

func show2PasswordDialog() -> (String, String, Bool) {
        let alert = NSAlert()
        alert.messageText = "Account Password".localized
        alert.informativeText = "Please input the password of this account".localized
        alert.alertStyle = .informational
        let password = PasswordViewController()
        alert.accessoryView = password.view
        alert.addButton(withTitle: "OK".localized)
        alert.addButton(withTitle: "Cancel".localized)
        let butSel = alert.runModal()
        if butSel == .alertFirstButtonReturn{
                return (password.PasswordTxt.stringValue, password.PasswordTxt2.stringValue, true)
        }
        return ("", "", false)
}

func touchDirectory(directory:String) throws ->URL{
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let url = paths[0].appendingPathComponent(directory)
        
        if !FileManager.default.fileExists(atPath: url.path){
                try FileManager.default.createDirectory(at:url, withIntermediateDirectories: true, attributes: nil)
        }
        
        return url
}
