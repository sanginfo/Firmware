//
//  SocketServer.h
//  SaentServiceDeamon
//
//  Created by APAC Builder on 8/31/15.
//  Copyright (c) 2015 APAC Builder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import "SocketProtocol.h"

@interface SocketServer : NSObject<NSStreamDelegate, SocketProtocol>

@property(nonatomic) NSInteger port;

@property(nonatomic, weak) id delegate;

@property(nonatomic) NSInteger numOfWriting;

-(id)init:delegate;

-(void)setup;

- (void) open;

- (void) close;

- (void) writeOut: (NSString *)s;

@end
