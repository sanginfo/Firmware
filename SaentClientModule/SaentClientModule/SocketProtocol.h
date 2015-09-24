//
//  SocketProtocol.h
//  SaentClientModule
//
//  Created by APAC Builder on 9/7/15.
//  Copyright (c) 2015 APAC Builder. All rights reserved.
//

#ifndef SaentClientModule_SocketProtocol_h
#define SaentClientModule_SocketProtocol_h

@protocol SocketProtocol <NSObject>

- (NSString *)getChatMessage;

- (void)appendChatMessage: (NSString *)message;

@end

#endif
