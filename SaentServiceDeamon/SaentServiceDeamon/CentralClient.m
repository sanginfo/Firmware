//
//  CentralClient.m
//  SaentServiceDeamon
//
//  Created by APAC Builder on 8/28/15.
//  Copyright (c) 2015 APAC Builder. All rights reserved.
//

#import "CentralClient.h"

static CentralClient *instance = nil;

@interface CentralClient () <CBCentralManagerDelegate, CBPeripheralDelegate>

@property(nonatomic, strong) CBCentralManager *manager;

@property(nonatomic, strong) NSMutableArray *listPeripheral;

@property(nonatomic, strong) CBPeripheral *connectedPeripheral;

@property(nonatomic, strong) CBService *connectedService;

@property(nonatomic, strong) CBCharacteristic *nConnectedCharacteristic;

@property(nonatomic, strong) CBCharacteristic *wConnectedCharacteristic;

@property(nonatomic, strong) BaseConfig *config;

@end

@implementation CentralClient

#pragma mark - init

- (id)init {
    
    self = [super init];
    
    if (self) {
        
        self.manager = [[CBCentralManager alloc] initWithDelegate:self
                                                            queue:dispatch_get_current_queue()];
        self.listPeripheral = [[NSMutableArray alloc] init];
        
        self.config = [[BaseConfig alloc] init];
        
        self.disconnected = NO;
    
    }
    
    return self;
}

+ (CentralClient*) getSingleton{

    @synchronized(self){
    
        if(instance == nil){
            
            instance = [[CentralClient alloc] init];
        
        }
        
        return instance;
        
    }

}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    
    NSMutableString* message = [[NSMutableString alloc] init];
    
    switch (central.state) {
            
        case CBCentralManagerStateUnsupported:
            
            NSLog(@"The platform/hardware doesn't support Bluetooth Low Energy.");
            
            [message appendFormat:@"[centralManagerDidUpdateState]The platform/hardware doesn't support Bluetooth Low Energy. \n"];
            
            break;
            
        case CBCentralManagerStateUnauthorized:
            
            NSLog(@"The app is not authorized to use Bluetooth Low Energy.");
            
            [message appendFormat:@"[centralManagerDidUpdateState]The app is not authorized to use Bluetooth Low Energy. \n"];
            
            break;
            
        case CBCentralManagerStatePoweredOff:
            
            NSLog(@"Bluetooth is currently powered off.");
            
            [message appendFormat:@"[centralManagerDidUpdateState]Bluetooth is currently powered off. \n"];
            
            break;
            
        case CBCentralManagerStatePoweredOn:
            
            NSLog(@"Bluetooth is currently powered on.");
            
            [message appendFormat:@"[centralManagerDidUpdateState]Bluetooth is currently powered on. \n"];
            
            break;
            
        default:
            
            NSLog(@"centralManager did update: %ld", central.state);
            
            [message appendFormat:@"[centralManagerDidUpdateState]centralManager did update: %ld \n", central.state];
            
            break;
    }
    
    [self.delegate centralClientSendResult:-1
                                   message:message
                                 exception:nil];
}

#pragma mark - method implement

- (void)centralClientDiscoverPeripherals {
    
    NSLog(@"BleModule: Scanning ...");
    
     NSDictionary *scanningOptions = @{ CBCentralManagerScanOptionAllowDuplicatesKey : @NO };
    
    [self.manager scanForPeripheralsWithServices:nil
                                         options:scanningOptions];

}

- (void)centralClientConnectPeripheral {
    
    NSLog(@"BleModule: Connecting ...");
    
    [self.manager stopScan];
    
    for (CBPeripheral *peripheral in self.listPeripheral) {
        
        if ([peripheral.identifier.UUIDString isEqualToString:self.peripheralUUID]) {
            
            [self.manager connectPeripheral:peripheral options:nil];
            
            return;
            
        }
    }
    
}

- (void)centralClientDisconnectPeripheral {
    
    self.disconnected = YES;
    
    NSLog(@"Disconnected...");
    
    [self cancelScanForPeripherals];
    
    [self.manager cancelPeripheralConnection:self.connectedPeripheral];
    
    [self unsubscribe];
    
    self.connectedPeripheral = nil;
    
}

- (void)centralClientWriteCharacteristic: (uint8)typeCommand
                              data: (NSData *)data {
    
    NSLog(@"BleModule: writeCharacteristic");
    
    if(!self.connectedService){
        
        NSLog(@"No service is found");
        
        return;
        
    }
    
    if(!self.wConnectedCharacteristic){
    
        NSLog(@"No characteristic for write( transfer)");
        
        return;
    
    }
    
    NSMutableString* message = [[NSMutableString alloc] init];
    
    [message appendFormat:@"Checking write permission.... \n"];
    
    if(self.wConnectedCharacteristic.properties &
       (CBCharacteristicPropertyWriteWithoutResponse | CBCharacteristicPropertyWrite)){
                
        NSLog(@"Characteristic %@ can write", self.wConnectedCharacteristic.UUID);
                
        Frame *frame = [Frame getSingleton];
                
        NSData *dataToWrite = [frame createCommand: typeCommand
                                                      data:data];
        
        [message appendFormat:@"Writing to characteristic with data: %@", dataToWrite];
        
        [self.delegate centralClientSendResult: -1
                                       message: message
                                     exception:nil];
                
        [self.connectedPeripheral writeValue:dataToWrite forCharacteristic:self.wConnectedCharacteristic
                                        type:CBCharacteristicWriteWithResponse];
                
        return;
                
    }else{
                
        [message appendFormat:@"Characteristic does not write \n"];
                
    }
    
    [self.delegate centralClientSendResult: -1
                                   message: message
                                 exception:nil];
    
}

- (void)centralClientSendNotification{

    

}

- (void)subscribe {
    
    if (!self.connectedService) {
        
        NSLog(@"No connected services for peripheralat all. Unable to subscribe");
        
        return;
        
    }
    
    if(!self.nConnectedCharacteristic){
        
        NSLog(@"No characteristic for read( notify)");
        
        return;
        
    }
    
    // send response
    
    NSMutableString *message = [[NSMutableString alloc] init];
    
    [message appendFormat:@"Subscribe... \n"];
    
    if (self.nConnectedCharacteristic.properties & CBCharacteristicPropertyNotify) {
    
        NSLog(@"Subscribed Characteristic: %@", self.nConnectedCharacteristic.UUID);
                
        [self.connectedPeripheral setNotifyValue:YES
                               forCharacteristic:self.nConnectedCharacteristic];
                
        return;
                
    }else{
                
        [message appendFormat:@"Do not subscribe... \n"];
                
    }
    
    [self.delegate centralClientSendResult: -1
                                   message: message
                                 exception:nil];

}

- (void)unsubscribe {
    
    if (!self.connectedService) return;
    
    for (CBCharacteristic *characteristic in self.connectedService.characteristics) {
        
        if([characteristic.UUID isEqualTo:self.charactericticReceiveUUID]){
            
            if (characteristic.properties & CBCharacteristicPropertyNotify) {
                
                NSLog(@"Unsubscribed Characteristic: %@", characteristic.UUID);
                
                [self.connectedPeripheral setNotifyValue:NO forCharacteristic:characteristic];
            }
            
        }
    }

}

- (void)cancelScanForPeripherals {
    
    [self.manager stopScan];
    
}

- (void)checkReady: (CBPeripheral*)peripheral{
    
    NSLog(@"Check ready...");
    
    [peripheral discoverServices:self.serviceUUIDs];
    
    return;

}

#pragma mark - delegate

- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI {
    
    @synchronized(self.listPeripheral){
        
        if(![self.listPeripheral containsObject:peripheral]){
            
            NSLog(@"Added this peripheral to list");
    
            [self.listPeripheral addObject: peripheral];
            
            NSLog(@"number peripheral of list: %lu", [self.listPeripheral count]);
        
            [self.delegate centralClientDiscoverPeripheralResult:self.listPeripheral];
            
        }
        
    }
    
}

- (void)centralManager:(CBCentralManager *)central
  didConnectPeripheral:(CBPeripheral *)peripheral {
    
    NSLog(@"Connecting to: %@", peripheral.name);
    
    self.connectedPeripheral = peripheral;
    
    // save devideID to config.xml file if connected to device
    [self.config saveDeviceID:peripheral.identifier.UUIDString];
    
    self.connectedPeripheral.delegate = self;
    
    [self checkReady:peripheral];
    
    // send response
    
    NSMutableString *message = [[NSMutableString alloc] init];
    
    [message appendFormat:@"Connected to %@ \n", peripheral.identifier.UUIDString];
    
    [message appendFormat:@"Checking services and characteristics... \n"];
    
    [self.delegate centralClientSendResult: -1
                                   message: message
                                 exception:nil];
    
}

- (void)centralManager:(CBCentralManager *)central
didDisconnectPeripheral:(CBPeripheral *)peripheral
                 error:(NSError *)error {
    
    NSLog(@"Disconnected to peripheral");
    
    // Send command back
    
    NSMutableString *message = [[NSMutableString alloc] init];
    
    [message appendFormat:@"Disconnected \n"];
    
    [self.delegate centralClientSendResult: -1
                                   message: message
                                 exception:nil];
    
    if(self.disconnected == NO){
        
        NSLog(@"Reconnecting...");
        
        [self centralClientDiscoverPeripherals];
        
        if(self.listPeripheral){
        
            if(self.peripheralUUID == nil){
                
                self.peripheralUUID = [self.config getDeviceID];
                
            }
            
            [self centralClientConnectPeripheral];
        
        }
        
    
    }else{
        
//        self.peripheralUUID = nil;
        
        self.connectedPeripheral = nil;
    
        self.connectedService = nil;
        
        self.wConnectedCharacteristic = nil;
        
        self.nConnectedCharacteristic = nil;
    
        NSLog(@"peripheralDidDisconnect: %@", peripheral);
        
    }
    
}

- (void)peripheral:(CBPeripheral *)peripheral
didDiscoverServices:(NSError *)error {
    
    if (error) {
        
        NSLog(@"Discover Services: Error: %@", error);
        
        return;
    }
    
    NSLog(@"Found Services Count: %ld", peripheral.services.count);
    
    for (CBService *service in peripheral.services) {
                        
        NSLog(@"FoundServiceUUID: %@", service.UUID);
        
        if ([self.serviceUUIDs containsObject:service.UUID]) {
            
            NSLog(@"Discover Characteristic");
            
            self.connectedService = service;
            
            [peripheral discoverCharacteristics:self.characteristicUUIDs forService:self.connectedService];
            
            return;
            
        }else{
        
            NSLog(@"Service does not match");
        
        }
        
    }
    
}

- (void)peripheral:(CBPeripheral *)peripheral
didDiscoverCharacteristicsForService:(CBService *)service
             error:(NSError *)error {
    
    if (error) {
        
        NSLog(@"Discover characteristic with Error: %@", error);
        
        return;
    }
    
    NSLog(@"Found %ld characteristic(s)", service.characteristics.count);
    
    for (CBCharacteristic *characteristic in service.characteristics) {
        
        NSLog(@"Characteristic: %@", characteristic.UUID);
        
        if([characteristic.UUID isEqualTo:self.charactericticReceiveUUID]){
            
            NSLog(@"Received Characteristic: %@", characteristic.UUID);
        
            self.nConnectedCharacteristic = characteristic;
            
            [self subscribe];
        
        }
        
        if([characteristic.UUID isEqualTo:self.charactericticTransferUUID]){
        
            NSLog(@"Tranfered Characteristic: %@", characteristic.UUID);
            
            self.wConnectedCharacteristic = characteristic;
        
        }
        
    }
    
    if(self.nConnectedCharacteristic && self.wConnectedCharacteristic){
    
        // send response
        
        NSMutableString *message = [[NSMutableString alloc] init];
        
        [message appendFormat:@"Service is ready for using \n"];
        
        [self.delegate centralClientSendResult: -1
                                       message: message
                                     exception:nil];
    
    }
    
}

- (void)peripheral:(CBPeripheral *)peripheral
didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error {
    
    NSMutableString* message = [[NSMutableString alloc] init];
    
    if (error) {
        
        [message appendFormat:@"Update notification state of characteristic(%@) is fail! \n", characteristic.UUID];
        
        NSLog(@"Error subscribe: %@", error);
        
        [self.delegate centralClientSendResult: -1
                                       message: message
                                     exception:nil];
        
        return;
        
    }
    
    NSLog(@"----------Notify success---------");
    
    [message appendFormat:@"Subscribe success \n"];
    
    [self.delegate centralClientSendResult: -1
                                   message: message
                                 exception:nil];
    
}

- (void)peripheral:(CBPeripheral *)peripheral
didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error {
    
    NSMutableString* message = [[NSMutableString alloc] init];
    
    if (error) {
        
        [message appendFormat:@"[Trigger]Update value error \n"];
        
        [self.delegate centralClientSendResult: -1
                                       message: message
                                     exception:nil];
        
        return;
    }
    
    NSData *data = characteristic.value;
    
    NSLog(@"Characteristic value: %@", data);
    
    Frame *frame = [Frame getSingleton];
    
    [frame parseData:data];
    
    NSLog(@"type: %04x", frame.type);
    
    NSLog(@"data: %04x", frame.data);
    
    NSString* command = [frame detectCommand];
    
    [message appendFormat:@"[Trigger]Detected Command: %@ \n", command];
    
    NSLog(@"[Trigger]Detected Command: %@ \n", command);
    
    [self.delegate centralClientSendResult: frame.data
                                   message: message
                                 exception:nil];
    
}

- (void)peripheral:(CBPeripheral *)peripheral
didWriteValueForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error {
    
    NSMutableString *message = [[NSMutableString alloc] init];
    
    if (error) {
        
        [message appendFormat:@"Error writing characteristic \n"];
        
        [self.delegate centralClientSendResult: -1
                                       message: message
                                     exception:nil];
        
        return;
        
    }
    
    [message appendFormat:@"Writing characteristic is success \n"];
    
    [self.delegate centralClientSendResult: -1
                                   message: message
                                 exception:nil];
    
}


@end
