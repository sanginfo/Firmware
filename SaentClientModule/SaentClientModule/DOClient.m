//
//  DOClient.m
//  SaentClientModule
//
//  Created by APAC Builder on 9/14/15.
//  Copyright (c) 2015 APAC Builder. All rights reserved.
//

#import "DOClient.h"

#import "BleConfig.h"

#import "DOClientProxy.h"

NSConnection* bleClientConnection;

DOClientProxy *theClientProxy;

@implementation DOClient

- (id)init{

    self = [super init];
    
    if(self){
        
        // init connection
        
        theClientProxy = [[DOClientProxy alloc] init];
        
        bleClientConnection = [NSConnection new];
        
        [bleClientConnection setRootObject:theClientProxy];
        
        if ([bleClientConnection registerName:@"saentClientHWServiceDeamon"] == FALSE){
            
            NSLog(@"[-] Failed to vend saentClientHWServiceDeamon");
            
        }
        else{
            
            NSLog(@"[+] Vended saentClientHWServiceDeamon successfully");
            
        }
        
        NSLog(@"[+] Starting run loop");
        
        // Set delegate
        
        theClientProxy.delegate = self;
        
        // Get connection from server
        
        NSConnection* bleServerConnection = [NSConnection connectionWithRegisteredName:@"saentServerHWServiceDeamon" host:nil];
        
        self.theServerProxy = [bleServerConnection rootProxy];
        
        if(self.theServerProxy){
        
            [self.theServerProxy connectToClient];
        
        }
        
    }
    
    return self;

}

#pragma mark - Using to receive event from DOClientProxy

- (void)discoverPeripheralsDelegate: (NSMutableArray*)listPeripherals{
    
    [self.delegate discoverPeripheralsDelegate:listPeripherals];

}

- (void)clientProxyReceiveDelegate: (UInt32)code
                           message: (NSString*)message
                         exception: (NSException*)exception{

    if(code == SWIPE_DOWN){
    
        [self.delegate onSwipeDown];
    
    }else if(code == SWIPE_UP){
    
        [self.delegate onSwipeUp];
    
    }else if(code == SWIPE_LEFT){
    
        [self.delegate onSwipeLeft];
    
    }else if(code == SWIPE_RIGHT){
    
        [self.delegate onSwipeRight];
    
    }else{
        
        [self.delegate updateStatusDelegate:code
                                    message:message
                                  exception:exception];
    }
    
    

}

#pragma mark - Using to send request to DOServer

- (void)discoverPeripherals{
    
    NSLog(@"Client app send request: DiscoverPeripheral");
    
    [self.theServerProxy discoverPeripherals];
    
}

- (void)distributedObjectDidDiscoverPeripheral: (NSMutableArray*)listPeripheral{
    
    

}

- (void)connectPeripheral{
    
    NSLog(@"Client app send request: ConnectPeripheral");
    
    // Set PeripheralUUID
    
    NSString* peripheralUUID = @"8AEB2190-1C15-4AF4-99AA-0C3F98E729C0";
    
    [self.theServerProxy connectPeripheral: peripheralUUID];
    
}

- (void)disconnectPeripheral{
    
    [self.theServerProxy disconnectPeripheral];
    
}

- (void)setTime: (const uint16) sessionDuration{
    
    NSMutableData *dataSend = [[NSMutableData alloc] init];
    
    [dataSend appendBytes:&sessionDuration length:sizeof(sessionDuration)];
    
    [self.theServerProxy sendCommand:SET_TIME data:dataSend];

}

- (void)startSession{

    [self.theServerProxy sendCommand:START_SESSION data:nil];

}

- (void)stopSession{

    [self.theServerProxy sendCommand:STOP_SESSION data:nil];

}

- (void)requestResult{

    [self.theServerProxy sendCommand:REQUEST_RESULT data:nil];

}

- (void)sendNotification{
    
    [self.theServerProxy sendNotification];
    
}

@end
