//
//  DOClient.h
//  SaentClientModule
//
//  Created by APAC Builder on 9/14/15.
//  Copyright (c) 2015 APAC Builder. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DOClientProxy.h"

#import "../../SaentServiceDeamon/SaentServiceDeamon/DOServerProxy.h"

@protocol DOClientDelegate;

@interface DOClient : NSObject<DOClientProxyDelegate>

@property(nonatomic, strong) DOServerProxy *theServerProxy;

@property(nonatomic, weak) id<DOClientDelegate> delegate;

- (void)discoverPeripherals;

- (void)connectPeripheral;

- (void)disconnectPeripheral;

- (void)setTime: (const uint16)sessionDuration;

- (void)startSession;

- (void)stopSession;

- (void)requestResult;

- (void)sendNotification;

@end

@protocol DOClientDelegate <NSObject>

- (void)discoverPeripheralsDelegate: (NSMutableArray*)listPeripherals;

- (void)onSwipeUp;

- (void)onSwipeDown;

- (void)onSwipeLeft;

- (void)onSwipeRight;

- (void)onClick;

- (void)updateStatusDelegate: (UInt32)code
                     message: (NSString*)status
                   exception: (NSException*)exception;

@end