//
//  DOServerProxy.m
//  SaentServiceDeamon
//
//  Created by APAC Builder on 9/17/15.
//  Copyright (c) 2015 APAC Builder. All rights reserved.
//

#import "DOServerProxy.h"

@implementation DOServerProxy

#pragma mark - send event to DOServer

- (void)connectToClient{
    
    [self.delegate serverProxyConnectToClient];
    
}

- (void)discoverPeripherals{
    
    [self.delegate serverProxyDiscoverPeripheral];
    
}

- (void)connectPeripheral: (NSString*)peripheralUUID{
    
    [self.delegate serverProxyConnectPeripheral:peripheralUUID];
    
}

- (void)disconnectPeripheral{
    
    [self.delegate serverProxyDisconnectPeripheral];
    
}

- (void)sendCommand: (uint8)typeCommand
               data: (NSData *)data{
    
    [self.delegate serverProxySendCommand:typeCommand
                                       data:data];
    
}

- (void)sendNotification{
    
    [self.delegate serverProxySendNotification];
    
}

@end
