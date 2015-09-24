//
//  SocketClient.m
//  SaentClientModule
//
//  Created by APAC Builder on 9/4/15.
//  Copyright (c) 2015 APAC Builder. All rights reserved.
//

#import "SocketClient.h"
#import "AppKit/AppKit.h"

CFReadStreamRef readStream;
CFWriteStreamRef writeStream;

NSInputStream *inputStream;
NSOutputStream *outputStream;

@implementation SocketClient

- (id) init:delegate{

    self = [super init];
    
    if(self){
        
        self.delegate = delegate;
        
    }
    
    return self;
    
}

- (void) setup{
    
    NSURL *url = [NSURL URLWithString:self.host];
    
    NSLog(@"Setting up connection to %@: %li", [url absoluteString], self.port);
    
    CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, (__bridge CFStringRef)[url host], self.port, &readStream, &writeStream);
    
    if(!CFWriteStreamOpen(writeStream)){
        
        NSLog(@"Error, writeStream not open");
        
        return;
        
    }
    
    [self open];
    
    NSLog(@"Status of outputStream: %lu", [outputStream streamStatus]);
    
}

- (void) open{
    
    NSLog(@"Opening streams.");
    
    inputStream = (__bridge NSInputStream *) readStream;
    outputStream = (__bridge NSOutputStream *) writeStream;
    
    //    [inputStream retain];
    //    [outputStream retain];
    
    [inputStream setDelegate:self];
    [outputStream setDelegate:self];
    
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [inputStream open];
    [outputStream open];
    
}

- (void) close{
    
    NSLog(@"Closing streams");
    
    [inputStream close];
    [outputStream close];
    
    [inputStream removeFromRunLoop:[NSRunLoop  currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [inputStream setDelegate:nil];
    [outputStream setDelegate:nil];
    
    //    [inputStream release];
    //    [outputStream release];
    
    inputStream = nil;
    outputStream = nil;
    
}

- (void) stream:(NSStream *)stream handleEvent:(NSStreamEvent)event{
    
    NSLog(@"Stream triggered");
    
    switch (event) {
            
        case NSStreamEventErrorOccurred: {
            
            NSError *error = [stream streamError];
            
            NSAlert *alert = [[NSAlert alloc] init];
            
            [alert setMessageText:@"Error reading stream!"];
            
            [alert setInformativeText: [NSString stringWithFormat:@"Error %li: %@", [error code], [error localizedDescription]]];
            
            [alert addButtonWithTitle:@"OK"];
            
            [stream close];
            
            //            [stream release];
            
            break;
            
        }
            
        case NSStreamEventHasSpaceAvailable: {
            
            if(stream == outputStream){
                
                NSLog(@"Output is ready");
                
            }
            
            break;
            
        }
            
        case NSStreamEventHasBytesAvailable: {
            
            if(stream == inputStream){
                
                NSLog(@"InputStream is ready");
                
                uint8_t buf[1024];
                
                unsigned int len = 0;
                
                len = [(NSInputStream *)inputStream read:buf maxLength:1024];
                
                if(len > 0 ){
                    
                    NSMutableData* data = [[NSMutableData alloc] init];
                    
                    [data appendBytes:buf length:len];
                    
                    NSString* s = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
                    
                    [self readIn:s];
                    
                    //                    [data release];
                    
                }
                
            }
            
            break;
            
        }
            
        case NSStreamEventEndEncountered: {
            
            [self close];
            
            break;
            
        }
            
        default: {
            
            NSLog(@"Stream is sending an Event: %lu", event);
            
            break;
            
        }
            
    }
    
}

- (void) readIn:(NSString *)s{
    
    NSString *msg = [NSString stringWithFormat:@"%@", s];
    
    [self.delegate appendChatMessage:[NSString stringWithFormat:@"%@", s]];
    
    
}

- (void) writeOut:(NSString *)s{
    
    uint8_t *buf = (uint8_t *)[s UTF8String];
    
    [outputStream write:buf maxLength:strlen((char *) buf)];
    
}


@end
