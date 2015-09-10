//
//  SocketProtocol.h
//  SaentServiceDeamon
//
//  Created by APAC Builder on 9/7/15.
//  Copyright (c) 2015 APAC Builder. All rights reserved.
//

#ifndef SaentServiceDeamon_SocketProtocol_h
#define SaentServiceDeamon_SocketProtocol_h

@protocol SocketProtocol <NSObject>

- (NSString *)getChatMessage;

- (void)appendChatMessage: (NSString *)message;

@end

#endif
