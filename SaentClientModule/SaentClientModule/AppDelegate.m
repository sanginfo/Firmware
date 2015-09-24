//
//  AppDelegate.m
//  SaentClientModule
//
//  Created by APAC Builder on 9/4/15.
//  Copyright (c) 2015 APAC Builder. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property(nonatomic, strong) DOClient *client;

@property(nonatomic) BOOL connected;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    self.client = [[DOClient alloc] init];
    
    self.client.delegate = self;
    
    self.connected = NO;
    
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    
    
    
}

- (void)appendLog: (NSString *)message {
    
    NSLog(@"%@", message);
    
    self.info.string = [self.info.string stringByAppendingFormat:@"%@", message];
    
    [self.info performSelector:@selector(scrollPageDown:) withObject:nil afterDelay:0];
    
}

- (IBAction)discoverPeripheral:(id)sender{
    
    [self appendLog:@"Discovering... \n"];

    [self.client discoverPeripherals];

}

- (IBAction)connectPeripheral:(id)sender{
    
    if(self.connected == NO){
    
        [self appendLog:@"Connecting... \n"];
        
        [self.client connectPeripheral];
        
        [(NSButton*)sender setTitle:@"Disconnnect"];
        
        self.connected = YES;
        
    
    }else{
    
        [self appendLog:@"Disconnecting...\n"];
        
        [self.client disconnectPeripheral];
        
        [(NSButton*)sender setTitle:@"Connect"];
        
        self.connected = NO;
    
    }
    
}

- (IBAction)setTime:(id)sender{
    
    [self appendLog:@"[SET_TIME]Sending request... \n"];
    
    const uint16 sessionDuration = 300;
    
    [self.client setTime:sessionDuration];
    
}

- (IBAction)startSession:(id)sender{
    
    [self appendLog:@"[START_SESSION]Sending request... \n"];
    
    [self.client startSession];
    
}

- (IBAction)stopSession:(id)sender{
    
    [self appendLog:@"[STOP_SESSION]Sending request... \n"];
    
    [self.client stopSession];
    
}

- (IBAction)requestResult:(id)sender{
    
    [self.client requestResult];
    
}

- (IBAction)sendNotification:(id)sender{

    [self.client sendNotification];

}

- (void)discoverPeripheralsDelegate: (NSMutableArray*)listPeripherals{
    
    [self appendLog: [NSString stringWithFormat:@"Found %li devices: \n", [listPeripherals count]]];
    
    for(CBPeripheral* peripheral in listPeripherals){
    
        [self appendLog: [NSString stringWithFormat:@"Peripheral UUID: %@ \n", peripheral.identifier.UUIDString]];
        
        [self appendLog: [NSString stringWithFormat:@"Peripheral Name: %@ \n", peripheral.name]];
    }
    

}

- (void)onSwipeUp{
    
    NSString *message = [[NSString alloc] initWithFormat:@"[event]onSwipeUp \n"];

    [self appendLog:message];

}

- (void)onSwipeDown{

    NSString *message = [[NSString alloc] initWithFormat:@"[event]onSwipeDown \n"];

    [self appendLog:message];

}

- (void)onSwipeLeft{
    
    NSString *message = [[NSString alloc] initWithFormat:@"[event]onSwipeLeft \n"];

    [self appendLog:message];

}

- (void)onSwipeRight{
    
    NSString *message = [[NSString alloc] initWithFormat:@"[event]onSwipeRight \n"];

    [self appendLog:message];

}

- (void)onClick{
    
    NSString *message = [[NSString alloc] initWithFormat:@"[event]onClick \n"];

    [self appendLog:message];

}

- (void)updateStatusDelegate: (UInt32)code
                     message: (NSString*)message
                   exception: (NSException*)exception{
    
    if([message isEqualToString:@""]){
    
        [self appendLog:@"No response \n"];
        
        return;
    
    }

    [self appendLog:message];

}

@end
