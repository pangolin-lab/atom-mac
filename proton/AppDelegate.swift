//
//  AppDelegate.swift
//  sofa
//
//  Created by wsli on 2019/1/30.
//  Copyright © 2019 com.nbs. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

        func applicationDidFinishLaunching(_ aNotification: Notification) {
                do {try Service.sharedInstance.amountService()}catch{
                        dialogOK(question: "Error", text: error.localizedDescription)
                    exit(-1)
                }
        }

        func applicationWillTerminate(_ aNotification: Notification) {
        }
}
