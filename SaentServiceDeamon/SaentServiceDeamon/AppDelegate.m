//
//  AppDelegate.m
//  SaentServiceDeamon
//
//  Created by APAC Builder on 8/27/15.
//  Copyright (c) 2015 APAC Builder. All rights reserved.
//

#import "AppDelegate.h"
#import "CentralClient.h"
#import "SocketServer.h"

@interface AppDelegate () <CentralClientDelegate>

// Bluetooth
@property (nonatomic, strong) CentralClient *central;

// Socket Server
@property(nonatomic, strong) SocketServer *server;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    // Setup Bluetooth Central implementation
    
    self.central = [[CentralClient alloc] initWithDelegate:self];
    
    self.central.peripheralUUID = @"8AEB2190-1C15-4AF4-99AA-0C3F98E729C0";
    
    self.central.serviceUUIDs = @[
                                  [CBUUID UUIDWithString:@"180d"]
                                  ];
    
    self.central.characteristicUUIDs = @[
                                         [CBUUID UUIDWithString:@"2a37"],
                                         [CBUUID UUIDWithString:@"2a38"],
                                         [CBUUID UUIDWithString:@"2a39"]
                                         ];
    
    self.central.charactericticReceiveUUID = [CBUUID UUIDWithString:@""];
    
    self.central.charactericticTransferUUID = [CBUUID UUIDWithString:@""];
    
    // Setup Socket Server
    
    self.server = [[SocketServer alloc] init:self];
    
    self.server.port = 2048;
    
    // Setup some basic hooks in the interface.
    
    self.bleInformation.editable = false;
    
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    
    [self.central disconnectPeripheral];
    
}

- (void)appendLogMessage:(NSString *)message {
    
    self.bleInformation.string = [self.bleInformation.string stringByAppendingFormat:@"%@\n", message];
    
    [self.bleInformation performSelector:@selector(scrollPageDown:) withObject:nil afterDelay:0];
    
}

- (NSString *)getChatMessage{

    NSString *msg = [[self.sockMessage textStorage] string];
    
    return msg;

}

- (void)clearChatMessage{

    [self.sockMessage setString:@""];
    
}

- (void)appendChatMessage: (NSString *)message {

    self.sockContent.string = [self.sockContent.string stringByAppendingFormat:@"%@\n", message];
    
    [self.sockContent performSelector:@selector(scrollPageDown:) withObject:nil afterDelay:0];

}

- (IBAction)discoverPeripherals:(id)sendor{
    
    [self.central discoverPeripherals];
    
}

- (IBAction)connectPeripheral:(id)sendor{
    
    [self.central connectPeripheral];
    
}

//- (IBAction)stopForPeripherals:(id)sendor{
//    
//}

- (IBAction)discoverServices:(id)sender{
    
    [self.central discoverServices];
    
}

- (IBAction)connectService:(id)sender{
    
    [self.central connectService];
    
}

- (IBAction)discoverCharacterics:(id)sender{
    
    [self.central discoverCharacterics];

}

- (IBAction)subscribe:(id)sender{
    
    [self.central subscribe];
    
}

- (IBAction)readValueOfCharacteristic:(id)sender{
    
    [self.central readValueOfCharacteristic];
    
}

- (IBAction)configureSeantHWService:(id)sendor{
    
}

- (IBAction)startServer:(id)sender{
    
    [self.server setup];
    
}

- (IBAction)sendMsgFromServer:(id)sender{
    
//    Setup server message from here
    
    NSString *msg = [self getChatMessage];
    
    [self.server writeOut:[NSString stringWithFormat:@"Server: %@", msg]];
    
    [self appendChatMessage: [NSString stringWithFormat:@"Server: %@", msg]];
    
    [self clearChatMessage];
    
}

// CentralClientDelegate

- (void)centralClientDidConnect:(CentralClient *)central {
    
    [self appendLogMessage:@"Connnected to Peripheral"];
    
    // [self.central subscribe];
    
}

- (void)centralClientDidDisconnect:(CentralClient *)central {
    
    [self appendLogMessage:@"Disconnected to Peripheral"];
    
}

- (void)centralClientDidSubscribe:(CentralClient *)central {
    
    [self appendLogMessage:@"Subscribed to Characteristic"];
    
}

- (void)centralClientDidUnsubscribe:(CentralClient *)central {
    
    [self appendLogMessage:@"Unsubscribed to Characteristic"];
    
}


- (void)centralClient:(CentralClient *)central
       characteristic:(CBCharacteristic *)characteristic
       didUpdateValue:(NSData *)value {
    
    NSString *printable = [[NSString alloc] initWithData:value encoding:NSUTF8StringEncoding];
    
    NSLog(@"didUpdateValue: %@", printable);
    
    [self appendLogMessage:[NSString stringWithFormat:@" >> Received Data: %@", printable]];
    
    // [self.central unsubscribe];
    
}

- (void)centralClient:(CentralClient *)central connectDidFail:(NSError *)error {
    
    NSLog(@"Error: %@", error);
    
    [self appendLogMessage:[error description]];
    
}

- (void)centralClient:(CentralClient *)central
requestForCharacteristic:(CBCharacteristic *)characteristic
              didFail:(NSError *)error {
    
    NSLog(@"Error: %@", error);
    
    [self appendLogMessage:[error description]];
    
}


@end
