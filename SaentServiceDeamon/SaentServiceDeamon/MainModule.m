//
//  MainModule.m
//  SaentServiceDeamon
//
//  Created by APAC Builder on 9/14/15.
//  Copyright (c) 2015 APAC Builder. All rights reserved.
//

#import "MainModule.h"

#import "DOServer.h"

#import "CentralClient.h"

@implementation MainModule

- (id)initWith: (CentralClient*)bleModule
        doModule: (DOServer*)doModule{

    self = [super init];
    
    if(self){
    
        self.bleModule = bleModule;
        
        self.doModule = doModule;
    
    }
    
    return self;

}

#pragma mark - BLE Delegate Implement - Using to send response to DOModule

- (void)centralClientDiscoverPeripheralResult:(NSMutableArray *)listPeripherals{
    
    [self.doModule disCoverPeripheralsResult:listPeripherals];
    
}

- (void)centralClientSendResult: (UInt32)code
                        message:(NSString *)message
                      exception:(NSException *)exception{

    [self.doModule distributedObjectReceiveResult:code
                                          message:message
                                        exception:exception];

}

#pragma mark - DO Delegate Implement - Using to send request to BleModule

- (void)distributedObjectDiscoverPeripheral{

    [self.bleModule centralClientDiscoverPeripherals];

}

- (void)distributedObjectConnectPeripheral:(NSString *)peripheralUUID{
    
    self.bleModule.peripheralUUID = peripheralUUID;
    
    [self.bleModule centralClientConnectPeripheral];
    
}

- (void)distributedObjectDisconnectPeripheral{

    [self.bleModule centralClientDisconnectPeripheral];

}

- (void)distributedObjectSendCommand:(uint8)typeCommand data:(NSData *)data{

    [self.bleModule centralClientWriteCharacteristic:typeCommand
                                                data:data];

}

- (void)distributedObjectSendNotification{


}

@end
