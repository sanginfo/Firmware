//
//  CentralClient.h
//  SaentServiceDeamon
//
//  Created by APAC Builder on 8/28/15.
//  Copyright (c) 2015 APAC Builder. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <IOBluetooth/IOBluetooth.h>

#import "Frame.h"

#import "BaseModule.h"

#import "BaseConfig.h"

#pragma mark - delegate

@protocol CentralClientDelegate;

#pragma mark - interface

@interface CentralClient : BaseModule

#pragma mark - properties

@property(nonatomic, strong) NSString *peripheralUUID;

@property (nonatomic, strong) NSArray *serviceUUIDs;

@property (nonatomic, strong) NSArray *characteristicUUIDs;

@property(nonatomic, strong) CBUUID *charactericticTransferUUID;

@property(nonatomic, strong) CBUUID *charactericticReceiveUUID;

@property (nonatomic, weak) id<CentralClientDelegate> delegate;

@property(nonatomic) BOOL disconnected;

#pragma mark - methods

+ (id) getSingleton;

- (void)centralClientDiscoverPeripherals;

- (void)centralClientConnectPeripheral;

- (void)centralClientDisconnectPeripheral;

- (void)centralClientWriteCharacteristic: (uint8)typeCommand
                       data: (NSData *)data;

@end

@protocol CentralClientDelegate <NSObject>

- (void)centralClientDiscoverPeripheralResult: (NSMutableArray*)listPeripherals;

- (void)centralClientSendResult: (UInt32)code
                        message: (NSString*)message
                      exception: (NSException*)exception;

@end