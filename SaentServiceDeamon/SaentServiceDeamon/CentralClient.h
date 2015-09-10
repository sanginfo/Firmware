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

@protocol CentralClientDelegate;

@interface CentralClient : NSObject

@property(nonatomic, strong) NSString *peripheralUUID;

@property (nonatomic, strong) NSString *serviceName;

@property (nonatomic, strong) NSArray *serviceUUIDs;

@property (nonatomic, strong) NSArray *characteristicUUIDs;

@property(nonatomic, strong) CBUUID *charactericticTransferUUID;

@property(nonatomic, strong) CBUUID *charactericticReceiveUUID;

@property(nonatomic, strong) NSMutableArray *peripherals;

@property (nonatomic, weak) id<CentralClientDelegate> delegate;

- (id)initWithDelegate:(id<CentralClientDelegate>)delegate;

- (void)discoverPeripherals;

- (void)connectPeripheral;

- (void)disconnectPeripheral;

- (void)discoverServices;

- (void)connectService;

- (void)discoverCharacterics;

- (void)subscribe;

- (void)unsubscribe;

- (void)readValueOfCharacteristic;

- (void)configService;

@end

@protocol CentralClientDelegate <NSObject>

- (void)centralClient:(CentralClient *)central
       connectDidFail:(NSError *)error;

- (void)centralClient:(CentralClient *)central
requestForCharacteristic:(CBCharacteristic *)characteristic
              didFail:(NSError *)error;

- (void)centralClientDidConnect:(CentralClient *)central;
- (void)centralClientDidDisconnect:(CentralClient *)central;

- (void)centralClientDidSubscribe:(CentralClient *)central;
- (void)centralClientDidUnsubscribe:(CentralClient *)central;

- (void)centralClient:(CentralClient *)central
       characteristic:(CBCharacteristic *)characteristic
       didUpdateValue:(NSData *)value;

@end


