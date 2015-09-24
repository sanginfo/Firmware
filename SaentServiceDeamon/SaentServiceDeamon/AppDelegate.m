//
//  AppDelegate.m
//  SaentServiceDeamon
//
//  Created by APAC Builder on 8/27/15.
//  Copyright (c) 2015 APAC Builder. All rights reserved.
//

#import "AppDelegate.h"

#import "CentralClient.h"

#import "DOServer.h"

#import "MainModule.h"

#import "BaseConfig.h"

@interface AppDelegate ()

@property(nonatomic, strong) CentralClient *bleModule;

@property(nonatomic, strong) DOServer *doModule;

@property (nonatomic, strong) MainModule *centralModule;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    // Init
    
    self.bleModule = [CentralClient getSingleton];
    
    self.doModule = [DOServer getSingleton];
    
    self.centralModule = [[MainModule alloc] initWith:self.bleModule
                                             doModule:self.doModule];
    
    // Set delegate
    
    [self.bleModule setDelegate:self.centralModule];
    
    [self.doModule setDelegate:self.centralModule];
    
    // Some config for bleModule - change it
    
    // serviceUUID = 6e400001 ba53f393 e0a9e50e 24dcca9e
    
    self.bleModule.serviceUUIDs = @[
                                     [CBUUID UUIDWithString:@"6E400001-BA53-F393-E0A9-E50E24DCCA9E"]
                                     ];
    
    self.bleModule.characteristicUUIDs = @[
                                    [CBUUID UUIDWithString:@"6E400003-BA53-F393-E0A9-E50E24DCCA9E"],
                                    [CBUUID UUIDWithString:@"6E400002-BA53-F393-E0A9-E50E24DCCA9E"]
                                    ];
    
    self.bleModule.charactericticReceiveUUID = [CBUUID UUIDWithString:@"6E400003-BA53-F393-E0A9-E50E24DCCA9E"];
    
    self.bleModule.charactericticTransferUUID = [CBUUID UUIDWithString:@"6E400002-BA53-F393-E0A9-E50E24DCCA9E"];
    
    // Setup some basic hooks in the interface.
    
    self.bleInformation.editable = false;
    
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    
    
    
}

- (void)appendLogMessage:(NSString *)message {
    
//    self.bleInformation.string = [self.bleInformation.string stringByAppendingFormat:@"%@\n", message];
//    
//    [self.bleInformation performSelector:@selector(scrollPageDown:) withObject:nil afterDelay:0];
    
}

- (NSString *)getChatMessage{

//    NSString *msg = [[self.sockMessage textStorage] string];

    NSString *msg = nil;
    
    return msg;

}

- (void)clearChatMessage{

//    [self.sockMessage setString:@""];
    
}

- (void)appendChatMessage: (NSString *)message {

//    self.sockContent.string = [self.sockContent.string stringByAppendingFormat:@"%@\n", message];
//    
//    [self.sockContent performSelector:@selector(scrollPageDown:) withObject:nil afterDelay:0];

}

- (IBAction)discoverPeripherals:(id)sendor{
    
    [self.bleModule centralClientDiscoverPeripherals];
    
}

- (IBAction)connectPeripheral:(id)sendor{
    
//    [self.central connectPeripheral];
    
}

//- (IBAction)disconnectPeripheral:(id)sendor{
//    
//}

- (IBAction)readCharacteristic:(id)sender{
    
//    [self.central readCharacteristic];
    
}

- (IBAction)setTime:(id)sender{
    
//    [self.central setTime:3600];
    
}

- (IBAction)startSession:(id)sender{
    
//    [self.central startSession];

}

- (IBAction)stopSession:(id)sender{
    
//    [self.central stopSession];
    
}

- (IBAction)requestResult:(id)sender{
    
//    [self.central requestResult];
    
}

- (IBAction)configureSeantHWService:(id)sendor{
    
    BaseConfig* config = [[BaseConfig alloc] init];
    
    [config saveDeviceID:@"1234567889"];
    
    NSString *deviceID = [config getDeviceID];
    
    NSLog(@"deviceID: %@", deviceID);
    
//    NSString *key = nil;
//    
//    NSString *value = nil;
//    
//    [config getConfig:&key
//                value:&value];
//    
//    NSLog(@"deviceID: %@", value);
    
}

- (IBAction)startServer:(id)sender{
    
    //    [self.server setup];
    
}

- (IBAction)sendMsgFromServer:(id)sender{
    
//    Setup server message from here
    
//    NSString *msg = [self getChatMessage];
//    
//    [self.server writeOut:[NSString stringWithFormat:@"Server: %@", msg]];
//    
//    [self appendChatMessage: [NSString stringWithFormat:@"Server: %@", msg]];
//    
//    [self clearChatMessage];
    
}

// CentralClientDelegate

- (void)centralClientDidConnect:(CentralClient *)central {
    
//    [self appendLogMessage:@"Connnected to Peripheral"];
    
    // [self.central subscribe];
    
}

- (void)centralClientDidDisconnect:(CentralClient *)central {
    
//    [self appendLogMessage:@"Disconnected to Peripheral"];
    
}

- (void)centralClientDidSubscribe:(CentralClient *)central {
    
//    [self appendLogMessage:@"Subscribed to Characteristic"];
    
}

- (void)centralClientDidUnsubscribe:(CentralClient *)central {
    
//    [self appendLogMessage:@"Unsubscribed to Characteristic"];
    
}


- (void)centralClient:(CentralClient *)central
       characteristic:(CBCharacteristic *)characteristic
       didUpdateValue:(NSData *)value {
    
//    NSString *printable = [[NSString alloc] initWithData:value encoding:NSUTF8StringEncoding];
//    
//    NSLog(@"didUpdateValue: %@", printable);
//    
//    [self appendLogMessage:[NSString stringWithFormat:@" >> Received Data: %@", printable]];
    
    // [self.central unsubscribe];
    
}

- (void)centralClient:(CentralClient *)central connectDidFail:(NSError *)error {
    
//    NSLog(@"Error: %@", error);
//    
//    [self appendLogMessage:[error description]];
    
}

- (void)centralClient:(CentralClient *)central
requestForCharacteristic:(CBCharacteristic *)characteristic
              didFail:(NSError *)error {
    
//    NSLog(@"Error: %@", error);
//    
//    [self appendLogMessage:[error description]];
    
}


@end
