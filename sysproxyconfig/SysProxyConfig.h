//
//  SysProxyConfig.h
//  sysproxyconfig
//
//  Created by Bencong Ri on 2019/3/6.
//  Copyright © 2019 pangolink.org All rights reserved.
//

#import <Foundation/Foundation.h>
#ifndef SysProxyConfig_h
#define SysProxyConfig_h
NSString* const kSysProxyConfigVersion = @"0.1.3";
int const PACServerPort = 51087;
int const ProxyLocalPort = 51080;
NSString* const kDefaultPacURL = @"http://127.0.0.1:\(PACServerPort)/proxy.pac";
#endif /* SysProxyConfig_h */
