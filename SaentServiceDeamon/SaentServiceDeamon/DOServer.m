//
//  DOServer.m
//  SaentServiceDeamon
//
//  Created by APAC Builder on 9/14/15.
//  Copyright (c) 2015 APAC Builder. All rights reserved.
//

#import "DOServer.h"

#import "DOServerProxy.h"

NSConnection* bleServerConnection;

DOServerProxy *serverProxy;

static DOServer* instance = nil;

@implementation DOServer

#pragma mark - init

- (id)init{

    self = [super init];
    
    if(self){
        
        // init
        
        serverProxy = [[DOServerProxy alloc] init];
    
        bleServerConnection = [NSConnection new];
        
        [bleServerConnection setRootObject:serverProxy];
        
        if ([bleServerConnection registerName:@"saentServerHWServiceDeamon"] == FALSE){
            
            NSLog(@"[-] Failed to vend saentServerHWServiceDeamon");
            
        }
        else{
            
            NSLog(@"[+] Vended saentServerHWServiceDeamon successfully");
            
        }
        
        NSLog(@"[+] Starting run loop");
        
        // Set delegate
        
        serverProxy.delegate = self;
    
    }
    
    return self;

}

+ (id)getSingleton{

    @synchronized(self){
    
        if(instance == nil){
        
            instance = [[DOServer alloc] init];
        
        }
        
        return instance;
    
    }

}

#pragma mark - update response

- (void)disCoverPeripheralsResult: (NSMutableArray*)listPeripherals{
    
    NSLog(@"Sendning result to Client Proxy with %lu peripheral", [listPeripherals count]);
    
    [self.theClientProxy discoverPeripheralsResult:listPeripherals];
    
}

- (void)distributedObjectReceiveResult:(UInt32)code
                               message:(NSString *)message
                             exception:(NSException *)exception{
    
    [self.theClientProxy clientProxyReceiveResult: code
                                          message: message
                                        exception:exception];
    
}

#pragma mark - Delegate implement - Using receive signal from DOServerProxy to DOServer

- (void)serverProxyConnectToClient{
    
    NSConnection* bleClientConnection = [NSConnection connectionWithRegisteredName:@"saentClientHWServiceDeamon" host:nil];
    
    self.theClientProxy = [bleClientConnection rootProxy];

}

- (void)serverProxyDiscoverPeripheral{
    
    [self.delegate distributedObjectDiscoverPeripheral];
    
}

- (void)serverProxyConnectPeripheral: (NSString*)peripheralUUID{
    
    [self.delegate distributedObjectConnectPeripheral:peripheralUUID];
    
}

- (void)serverProxyDisconnectPeripheral{
    
    [self.delegate distributedObjectDisconnectPeripheral];

}

- (void)serverProxySendCommand: (uint8)typeCommand
                            data: (NSData *)data{

    [self.delegate distributedObjectSendCommand:typeCommand
                                           data:data];

}

- (void)serverProxySendNotification{

//    [self.central sendNotification];

}

@end
