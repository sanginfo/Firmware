//
//  AppDelegate.h
//  SaentClientModule
//
//  Created by APAC Builder on 9/4/15.
//  Copyright (c) 2015 APAC Builder. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <IOBluetooth/IOBluetooth.h>

#import "BleConfig.h"

#import "SocketClient.h"

#import "DOClient.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, DOClientDelegate>

@property (weak) IBOutlet NSWindow *window;

@property(assign) IBOutlet NSTextField *status;

@property(assign) IBOutlet NSTextView *info;

@property(assign) IBOutlet NSTextView *command;

- (IBAction)discoverPeripheral:(id)sender;

- (IBAction)connectPeripheral:(id)sender;

- (IBAction)setTime:(id)sender;

- (IBAction)startSession:(id)sender;

- (IBAction)stopSession:(id)sender;

- (IBAction)requestResult:(id)sender;

- (IBAction)sendNotification:(id)sender;

@end

