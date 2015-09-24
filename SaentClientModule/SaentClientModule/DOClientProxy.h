//
//  DOClientProxy.h
//  SaentClientModule
//
//  Created by APAC Builder on 9/17/15.
//  Copyright (c) 2015 APAC Builder. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <IOBluetooth/IOBluetooth.h>

@protocol DOClientProxyDelegate;

@interface DOClientProxy : NSObject

@property(nonatomic, weak)id<DOClientProxyDelegate> delegate;

#pragma mark - Using to receive response from MainModule

- (void)discoverPeripheralsResult: (NSMutableArray*)listPeripherals;

- (void)clientProxyReceiveResult: (UInt32)code
                         message: (NSString*)status
                       exception: (NSException*)exception;

@end

@protocol DOClientProxyDelegate <NSObject>

- (void)discoverPeripheralsDelegate: (NSMutableArray*)listPeripherals;

- (void)clientProxyReceiveDelegate: (UInt32)code
                           message: (NSString*)message
                         exception: (NSException*)exception;

@end