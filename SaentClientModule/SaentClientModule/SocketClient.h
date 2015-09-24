//
//  SocketClient.h
//  SaentClientModule
//
//  Created by APAC Builder on 9/4/15.
//  Copyright (c) 2015 APAC Builder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SocketProtocol.h"

@interface SocketClient : NSObject <NSStreamDelegate, SocketProtocol>

@property(nonatomic, weak) id delegate;

@property(nonatomic, strong) NSString *host;

@property(nonatomic) NSInteger port;

- (id) init:delegate;

- (void) setup;

- (void) open;

- (void) close;

- (void) writeOut: (NSString *)s;

@end
