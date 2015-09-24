//
//  DOServerProxy.h
//  SaentServiceDeamon
//
//  Created by APAC Builder on 9/17/15.
//  Copyright (c) 2015 APAC Builder. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <IOBluetooth/IOBluetooth.h>

@protocol DOServerProxyDelegate;

@interface DOServerProxy : NSObject

@property(nonatomic, weak)id<DOServerProxyDelegate> delegate;

#pragma mark - Using to send request to DOServer

- (void)connectToClient;

- (void)discoverPeripherals;

- (void)connectPeripheral: (NSString*)peripheralUUID;

- (void)disconnectPeripheral;

- (void)sendCommand: (uint8)typeCommand
               data: (NSData *)data;

- (void)sendNotification;

@end

@protocol DOServerProxyDelegate <NSObject>

- (void)serverProxyConnectToClient;

- (void)serverProxyDiscoverPeripheral;

- (void)serverProxyConnectPeripheral: (NSString*) peripheralUUID;

- (void)serverProxyDisconnectPeripheral;

- (void)serverProxySendCommand: (uint8)typeCommand
                            data: (NSData *)data;

- (void)serverProxySendNotification;

@end
