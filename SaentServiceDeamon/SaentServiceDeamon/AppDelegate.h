//
//  AppDelegate.h
//  SaentServiceDeamon
//
//  Created by APAC Builder on 8/27/15.
//  Copyright (c) 2015 APAC Builder. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "SocketProtocol.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, SocketProtocol>

@property (weak) IBOutlet NSWindow *window;

@property(assign) IBOutlet NSTextField *bleStatus;

@property(assign) IBOutlet NSTextView *bleInformation;

@property(assign) IBOutlet NSTextField *sockStatus;

@property(assign) IBOutlet NSTextView *sockContent;

@property(assign) IBOutlet NSTextView *sockMessage;

- (IBAction)discoverPeripherals:(id)sender;

- (IBAction)connectPeripheral:(id)sender;

//- (IBAction)disconnectPeripheral:(id)sender;

- (IBAction)readCharacteristic:(id)sender;

- (IBAction)setTime:(id)sender;

- (IBAction)startSession:(id)sender;

- (IBAction)stopSession:(id)sender;

- (IBAction)requestResult:(id)sender;

- (IBAction)configureSeantHWService:(id)sender;



- (IBAction)startServer:(id)sender;

- (IBAction)sendMsgFromServer:(id)sender;

@end

