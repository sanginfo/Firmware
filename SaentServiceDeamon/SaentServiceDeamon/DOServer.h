//
//  DOServer.h
//  SaentServiceDeamon
//
//  Created by APAC Builder on 9/14/15.
//  Copyright (c) 2015 APAC Builder. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <IOBluetooth/IOBluetooth.h>

#import "BaseModule.h"

#import "DOServerProxy.h"

#import "../../SaentClientModule/SaentClientModule/DOClientProxy.h"

@protocol DOServerDelegate;

@interface DOServer : BaseModule<DOServerProxyDelegate>

@property(nonatomic, strong) DOServer* instance;

@property(nonatomic, strong) NSMutableArray *listPeripheral;

@property(nonatomic, weak) id<DOServerDelegate> delegate;

@property(nonatomic, strong) DOClientProxy *theClientProxy;

+ (id)getSingleton;

- (void)disCoverPeripheralsResult: (NSMutableArray*)listPeripherals;

- (void)distributedObjectReceiveResult: (UInt32)code
                               message: (NSString*)message
                             exception: (NSException*)exception;

@end

@protocol DOServerDelegate <NSObject>

- (void)distributedObjectDiscoverPeripheral;

- (void)distributedObjectConnectPeripheral: (NSString*) peripheralUUID;

- (void)distributedObjectDisconnectPeripheral;

- (void)distributedObjectSendCommand: (uint8)typeCommand
                                data: (NSData *)data;

- (void)distributedObjectSendNotification;

@end
