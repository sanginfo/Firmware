//
//  CentralClient.m
//  SaentServiceDeamon
//
//  Created by APAC Builder on 8/28/15.
//  Copyright (c) 2015 APAC Builder. All rights reserved.
//

#import "CentralClient.h"

static const NSTimeInterval scanningTimeout = 20.0;

static const NSTimeInterval connectingTimeout = 20.0;

static const NSTimeInterval requestTimeout = 20.0;

@interface CentralClient () <CBCentralManagerDelegate, CBPeripheralDelegate>

@property(nonatomic, strong) CBCentralManager *manager;

@property(nonatomic, strong) NSMutableArray *listPeripheral;

@property(nonatomic, strong) CBPeripheral *connectedPeripheral;

@property(nonatomic, strong) CBService *connectedService;

@property(nonatomic, assign) BOOL subscribeWhenCharacteristicsFound;

@property(nonatomic, assign) BOOL connectWhenReady;

@end

@implementation CentralClient

+ (NSError *)errorWithDescription:(NSString *)description {
    
    static NSString * const centralClientErrorDomain = @"com.apac.CentralClient";
    
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey : description};
    
    return [NSError errorWithDomain:centralClientErrorDomain
                               code:-1
                           userInfo:userInfo];
}

- (id)init {
    return [self initWithDelegate:nil];
}

- (id)initWithDelegate:(id<CentralClientDelegate>)delegate {
    
    self = [super init];
    
    if (self) {
        
        self.delegate = delegate;
        
        self.manager = [[CBCentralManager alloc] initWithDelegate:self
                                                            queue:dispatch_get_current_queue()];
        self.listPeripheral = [[NSMutableArray alloc] init];
    }
    
    return self;
}

// CBCentralManagerDelegate - central update

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    
    switch (central.state) {
            
        case CBCentralManagerStateUnsupported:
            
            NSLog(@"The platform/hardware doesn't support Bluetooth Low Energy.");
            
            break;
            
        case CBCentralManagerStateUnauthorized:
            
            NSLog(@"The app is not authorized to use Bluetooth Low Energy.");
            
            break;
            
        case CBCentralManagerStatePoweredOff:
            
            NSLog(@"Bluetooth is currently powered off.");
            
            break;
            
        case CBCentralManagerStatePoweredOn:
            
            NSLog(@"Bluetooth is currently powered on.");
            
            if (self.subscribeWhenCharacteristicsFound) {
                
                if (self.connectedService) {
                    
                    [self subscribe];
                    
                    return;
                }
            }
            
            if (self.connectWhenReady) {
                
                [self connectPeripheral];
                
                return;
            }
            
            break;
            
        default:
            
            NSLog(@"centralManager did update: %ld", central.state);
            
            break;
    }
}

/* ------------ Periperal section - Start -------- */

// Scan

- (void)discoverPeripherals {
    
    if (self.manager.state != CBCentralManagerStatePoweredOn) {
        
        self.connectWhenReady = YES;
        
        return;
    }
    
    NSLog(@"Scanning ...");
    
    [self startScanningTimeoutMonitor];
    
    // NSDictionary *scanningOptions = @{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES };
    
    [self.manager scanForPeripheralsWithServices:nil
                                         options:nil];
    
    self.connectWhenReady = NO;
    
    self.subscribeWhenCharacteristicsFound = NO;
}

- (void)cancelScanForPeripherals {
    
    [self.manager stopScan];
    
}

// Scan Timeout

- (void)startScanningTimeoutMonitor {
    
    [self cancelScanningTimeoutMonitor];
    
    [self performSelector:@selector(scanningDidTimeout)
               withObject:nil
               afterDelay:scanningTimeout];
    
}

- (void)cancelScanningTimeoutMonitor {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(scanningDidTimeout)
                                               object:nil];
}

- (void)scanningDidTimeout {
    
    NSLog(@"Scanning did timeout");
    
    NSError *error = [[self class] errorWithDescription:@"Unable to find a BTLE device."];
    
    [self.delegate centralClient:self connectDidFail:error];
    
    [self cancelScanForPeripherals];
}

// CBPeripheralDelegate - after scanning peripherals

- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI {
    
    NSLog(@"Peripheral Information: ");
    
    CBUUID *peripheralUUID = [CBUUID UUIDWithCFUUID:peripheral.UUID];
    
    NSLog(@"CFUUID: %@", peripheral.identifier.UUIDString);
    
    NSLog(@"CBUUID: %@", peripheralUUID);
    
    NSLog(@"Name: %@", peripheral.name);
    
    NSLog(@"Advertisment Data: %@", advertisementData);
    
    NSLog(@"RSSI: %@", RSSI);
    
    [self.listPeripheral addObject: peripheral];
    
}


// Connect

- (void)connectPeripheral {
    
    NSLog(@"Connecting...");
    
    [self cancelScanningTimeoutMonitor];
    
    [self.manager stopScan];
    
    for (CBPeripheral *peripheral in self.listPeripheral) {
        
        NSLog(@"Checking %@", peripheral.identifier.UUIDString);
        
        if ([peripheral.identifier.UUIDString isEqualToString:self.peripheralUUID]) {
            
            NSLog(@"Connecting ... %@", peripheral.identifier.UUIDString);
            
            [self.manager connectPeripheral:peripheral options:nil];
            
            [self startConnectionTimeoutMonitor:peripheral];
            
            return;
            
        }
    }
    
}

// Connect Timeout

- (void)startConnectionTimeoutMonitor:(CBPeripheral *)peripheral {
    
    [self cancelConnectionTimeoutMonitor:peripheral];
    
    [self performSelector:@selector(connectionDidTimeout:)
               withObject:peripheral
               afterDelay:connectingTimeout];
    
}

- (void)cancelConnectionTimeoutMonitor:(CBPeripheral *)peripheral {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(connectionDidTimeout:)
                                               object:peripheral];
    
}

- (void)connectionDidTimeout:(CBPeripheral *)peripheral {
    
    NSLog(@"connectionDidTimeout: %@", peripheral.UUID);
    
    NSError *error = [[self class] errorWithDescription:@"Unable to connect to BTLE device."];
    
    [self.delegate centralClient:self connectDidFail:error];
    
    [self.manager cancelPeripheralConnection:peripheral];
    
}

- (void)centralManager:(CBCentralManager *)central
didFailToConnectPeripheral:(CBPeripheral *)peripheral
                 error:(NSError *)error {
    
    NSLog(@"failedToConnectPeripheral: %@", peripheral);
    
    [self cancelConnectionTimeoutMonitor:peripheral];
    
    [self.delegate centralClient:self connectDidFail:error];
    
}

// CBPeripheralDelegate - after connecting to peripheral

- (void)centralManager:(CBCentralManager *)central
  didConnectPeripheral:(CBPeripheral *)peripheral {
    
    NSLog(@"Connected: %@", peripheral.name);
    
    [self cancelConnectionTimeoutMonitor:peripheral];
    
    self.connectedPeripheral = peripheral;
    
    //    [self discoverServices:peripheral];
    
}

- (void)disconnectPeripheral {
    
    [self cancelScanForPeripherals];
    
    [self.manager cancelPeripheralConnection:self.connectedPeripheral];
    
    self.connectedPeripheral = nil;
    
}

- (void)centralManager:(CBCentralManager *)central
didDisconnectPeripheral:(CBPeripheral *)peripheral
                 error:(NSError *)error {
    
    self.connectedPeripheral = nil;
    
    self.connectedService = nil;
    
    NSLog(@"peripheralDidDisconnect: %@", peripheral);
    
    [self.delegate centralClientDidDisconnect:self];
    
}

/* ------------ Periperal section - End -------- */


/* ------------ Service section - Start -------- */

- (void)discoverServices{
    
    NSLog(@"Discovering service...");
    
    [self discoverServices:self.connectedPeripheral];
    
}

- (void)discoverServices:(CBPeripheral *)peripheral {
    
    [peripheral setDelegate:self];
    
    [peripheral discoverServices:nil];
    
}

// CBPeripheralDelegate - after discovering service of peripheral

- (void)peripheral:(CBPeripheral *)peripheral
didDiscoverServices:(NSError *)error {
    
    if (error) {
        
        [self.delegate centralClient:self connectDidFail:error];
        
        NSLog(@"Discover Services: Error: %@", error);
        
        return;
    }
    
    NSLog(@"Services Count: %ld", peripheral.services.count);
    
    for (CBService *service in peripheral.services) {
        
        NSLog(@"ServiceUUID: %@", service.UUID);
        
    }
    
}

- (void)connectService{
    
    NSLog(@"Connecting to service....");
    
    for (CBService *service in self.connectedPeripheral.services) {
    
        NSLog(@"Connected service: %@", service.UUID);
        
        if (self.connectedService) continue;
        
        if ([self.serviceUUIDs containsObject:service.UUID]) {
        
            self.connectedService = service;
                    
        }
        
    }
    
}

/* ------------ Service section - End -------- */

/* ------------ Characteric section - Start -------- */

- (void)discoverCharacterics{
    
    NSLog(@"Discovering Service Characteristics....");
    
    [self discoverCharacteristics:self.connectedService];
    
}

- (void)discoverCharacteristics:(CBService *)service {
    
    [self.connectedPeripheral discoverCharacteristics:nil
                                           forService:service];
    
}


// Request Timeout

- (void)startRequestTimeout:(CBCharacteristic *)characteristic {
    
    [self cancelRequestTimeoutMonitor:characteristic];
    
    [self performSelector:@selector(requestDidTimeout:)
               withObject:characteristic
               afterDelay:requestTimeout];
    
}

- (void)cancelRequestTimeoutMonitor:(CBCharacteristic *)characteristic {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(requestDidTimeout:)
                                               object:characteristic];
    
}

- (void)requestDidTimeout:(CBCharacteristic *)characteristic {
    
    NSLog(@"requestDidTimeout: %@", characteristic);
    
    NSError *error = [[self class] errorWithDescription:@"Unable to request data from BTLE device."];
    
    [self.delegate centralClient:self
        requestForCharacteristic:characteristic
                         didFail:error];
    
    [self.connectedPeripheral setNotifyValue:NO
                           forCharacteristic:characteristic];
    
}

// CBPeripheralDelegate - after discovering characteristics for service

- (void)peripheral:(CBPeripheral *)peripheral
didDiscoverCharacteristicsForService:(CBService *)service
             error:(NSError *)error {
    
    if (error) {
        
        [self.delegate centralClient:self connectDidFail:error];
        
        NSLog(@"Discover characteristic with Error: %@", error);
        
        return;
    }
    
    NSLog(@"Found %ld characteristic(s)", service.characteristics.count);
    
    for (CBCharacteristic *characteristic in service.characteristics) {
        
        NSLog(@"Characteristic: %@", characteristic.UUID);
        
    }
    
}

- (void)subscribe {
    
    if (!self.connectedService) {
        
        NSLog(@"No connected services for peripheralat all. Unable to subscribe");
        
        return;
        
    }
    
    for (CBCharacteristic *characteristic in self.connectedService.characteristics) {
        
        if (characteristic.properties & CBCharacteristicPropertyNotify) {
            
            NSLog(@"Subscribed Characteristic: %@", characteristic.UUID);

            [self.connectedPeripheral setNotifyValue:YES
                                   forCharacteristic:characteristic];
            
        }else{
        
            NSLog(@"Can not subscribe characteristic: %@", characteristic.UUID);
            
        }
        
    }
    
    [self.delegate centralClientDidSubscribe:self];
    
}

- (void)unsubscribe {
    
    if (!self.connectedService) return;
    
    for (CBCharacteristic *characteristic in self.connectedService.characteristics) {
        
        if (characteristic.properties & CBCharacteristicPropertyNotify) {
            
            NSLog(@"Unsubscribed Characteristic: %@", characteristic.UUID);
            
            [self.connectedPeripheral setNotifyValue:NO forCharacteristic:characteristic];
        }
    }
    
    [self.delegate centralClientDidUnsubscribe:self];
}

// Callback after subcribe

- (void)peripheral:(CBPeripheral *)peripheral
didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error {
    
    if (error) {
        
        NSLog(@"Error changing notification state: %@", [error localizedDescription]);
        
        return;
        
    }
    
}

- (void)readValueOfCharacteristic{
    
    for (CBCharacteristic *characteristic in self.connectedService.characteristics) {
        
        if(characteristic.properties & CBCharacteristicPropertyRead){
        
            NSLog(@"Characteristic %@ can read", characteristic.UUID);
            
            [self.connectedPeripheral readValueForCharacteristic:characteristic];
            
        }else{
        
            NSLog(@"Characteristic %@ can not read", characteristic.UUID);
            
        }
        
    }
    
}

- (void)peripheral:(CBPeripheral *)peripheral
didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error {
    
    [self cancelRequestTimeoutMonitor:characteristic];
    
    if (error) {
        
        NSLog(@"Update Value Error: %@", error);
        
        [self.delegate centralClient:self requestForCharacteristic:characteristic didFail:error];
        
        return;
    }
    
    NSData *data = characteristic.value;
    
    NSLog(@"Update Value For Char: Value: %@", data);
    
    Frame *frame = [[Frame alloc] initWithData:data];
    
    [frame detectCommand];
    
    [self.delegate centralClient:self
                  characteristic:characteristic
                  didUpdateValue:characteristic.value];
    
}

- (void)setTime{

    const uint16 sessionTime = 300;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    
    [data appendBytes:&sessionTime length:sizeof(sessionTime)];
    
    [self writeValueOfCharacteristic:SET_TIME
                              data:data];

}

- (void)startSession{

    [self writeValueOfCharacteristic:START_SESSION
                                data:nil];

}

- (void)stopSession{

    [self writeValueOfCharacteristic:STOP_SESSION
                                data:nil];

}

- (void)requireRequest{

    [self writeValueOfCharacteristic:REQUEST_RESULT
                                data:nil];

}

- (void)writeValueOfCharacteristic: (uint8)typeCommand
                            data: (NSData *)data {
    
    for (CBCharacteristic *characteristic in self.connectedService.characteristics) {
        
        if([characteristic.UUID isEqual:self.charactericticTransferUUID]){
        
            if(characteristic.properties & (CBCharacteristicWriteWithResponse || CBCharacteristicWriteWithoutResponse)){
            
                NSLog(@"Characteristic %@ can read", characteristic.UUID);
                
                Frame *frame = [[Frame alloc] init];
                
                NSData *dataToWrite = [frame createCommand: typeCommand
                                                      data:data];
            
                [self.connectedPeripheral writeValue:dataToWrite forCharacteristic:characteristic
                                            type:CBCharacteristicWriteWithResponse];
            
            }else{
            
                NSLog(@"Characteristic %@ can not read", characteristic.UUID);
            
            }
            
            return;
            
        }
        
    }

}

- (void)peripheral:(CBPeripheral *)peripheral
didWriteValueForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error {
    
    if (error) {
        
        NSLog(@"Error writing characteristic value: %@", [error localizedDescription]);
        
    }
    
}

/* ------------ Characteric section - End -------- */

@end
