//
//  SocketServer.m
//  SaentServiceDeamon
//
//  Created by APAC Builder on 8/31/15.
//  Copyright (c) 2015 APAC Builder. All rights reserved.
//

#import "SocketServer.h"
#import "AppKit/AppKit.h"

CFReadStreamRef readStream;
CFWriteStreamRef writeStream;

NSInputStream *inputStream;
NSOutputStream *outputStream;

@implementation SocketServer

- (id)init: delegate {
    
    self = [super init];
    
    if(self){
        
        self.delegate = delegate;
        
        self.numOfWriting = 0;
        
    }
    
    return self;
    
}

-(void) setup{
    
    CFSocketRef TCPServer;
        
    char punchline[] = "To get to the order side!";
    
    int yes = 1;
    
    CFSocketContext CTX = {0, punchline, nil, nil, nil};
    CTX.info = (__bridge void *)(self);
    
    TCPServer = CFSocketCreate(
        kCFAllocatorDefault,
        PF_LOCAL,
        SOCK_STREAM,
        IPPROTO_TCP,
        kCFSocketAcceptCallBack,
        (CFSocketCallBack)&AcceptCallBack,
        &CTX
    );
    
    if(TCPServer == NULL){
        
        NSLog(@"Server socket is not created");
        
        return;
        
    }else{
        
        NSLog(@"Server socket is created");
        
    }
    
    setsockopt(CFSocketGetNative(TCPServer), SOL_SOCKET, SO_REUSEADDR, (void*) &yes, sizeof(yes));
    
    struct sockaddr_in addr;
    
    memset(&addr, 0, sizeof(addr));
    
    addr.sin_len = sizeof(addr);
    
    addr.sin_family = AF_INET;
    
    addr.sin_port = htons(self.port);
    
    addr.sin_addr.s_addr = htonl(INADDR_ANY);
    
    NSData *address = [NSData dataWithBytes:&addr length:sizeof(addr)];
    
    if(CFSocketSetAddress(TCPServer, (CFDataRef)address) != kCFSocketSuccess){
        
        NSLog(@"CFSocketSetAddress() failed: %@ \n", stderr);
        
        CFRelease(TCPServer);
        
        return;
    }
    
    CFRunLoopSourceRef sourceRef = CFSocketCreateRunLoopSource(kCFAllocatorDefault, TCPServer, 0);
    
    CFRunLoopAddSource(CFRunLoopGetCurrent(), sourceRef, kCFRunLoopCommonModes);
    
    CFRelease(sourceRef);
    
}

static void AcceptCallBack(CFSocketRef socket, CFSocketCallBackType type, CFDataRef address, const void *data, void *info) {
  
    CFSocketNativeHandle sock = *(CFSocketNativeHandle *) data;
    
    CFStreamCreatePairWithSocket(kCFAllocatorDefault, sock, &readStream, &writeStream);
    
    if(!CFWriteStreamOpen(writeStream)){
        
        NSLog(@"Error, writeStream not open");
        
        return;
        
    }
    
    SocketServer* socketServer = (__bridge SocketServer*)info;
    
    [socketServer open];
    
    NSLog(@"Status of outputStream: %lu", [outputStream streamStatus]);
    
    return;
    
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
                
                self.numOfWriting++;
                
                NSLog(@"InputStream is ready %ld", self.numOfWriting);
                
                uint8_t buf[1024];
                
                unsigned int len = 0;
                
                len = [(NSInputStream *)inputStream read:buf maxLength:1024];
                
                if(len > 0 ){
                    
                    NSMutableData* data = [[NSMutableData alloc] init];
                    
                    [data appendBytes:buf length:len];
                    
                    NSString* s = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
                    
                    [self readIn:s];
                    
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
    
    [self.delegate appendChatMessage:[NSString stringWithFormat:@"%@", s]];
    
    
    
}

- (void) writeOut:(NSString *)s{
    
    uint8_t *buf = (uint8_t *)[s UTF8String];
    
    [outputStream write:buf maxLength:strlen((char *) buf)];
    
}

@end
