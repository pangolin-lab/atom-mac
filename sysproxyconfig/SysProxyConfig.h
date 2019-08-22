//
//  SysProxyConfig.h
//  sysproxyconfig
//
//  Created by Bencong Ri on 2019/3/6.
//  Copyright © 2019 com.proton. All rights reserved.
//

#ifndef SysProxyConfig_h
#define SysProxyConfig_h

#import <Foundation/Foundation.h>
NSString* const kSysProxyConfigVersion = @"0.1.3";
NSString* const kDefaultPacURL = @"http://127.0.0.1:51087/proxy.pac";
int const PACServerPort = 51087;
int const ProxyLocalPort = 51080;
#endif /* SysProxyConfig_h */
