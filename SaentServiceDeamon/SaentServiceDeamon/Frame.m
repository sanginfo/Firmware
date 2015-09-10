//
//  Frame.m
//  SaentServiceDeamon
//
//  Created by APAC Builder on 9/8/15.
//  Copyright (c) 2015 APAC Builder. All rights reserved.
//

#import "Frame.h"

const uint8 TYPE_OFFSET = 0;

const uint8 LENGTH_OFFSET = 2;

const uint8 FRAME_OFFSET = 4;

const uint8 CHECK_SUM_OFFSET = 6;

const uint8 DATA_OFFSET = 8;

@implementation Frame

- (UInt16) bleBufferToUInt16:(UInt8 *)buffer{
    
    UInt8 uint16Buffer[2];
    
    if(CFByteOrderGetCurrent() == CFByteOrderBigEndian){
        
        uint16Buffer[0] = buffer[1];
        
        uint16Buffer[1] = buffer[0];
        
    }else{
        
        uint16Buffer[0] = buffer[0];
        
        uint16Buffer[1] = buffer[1];
        
    }
    
    return *((UInt16 *)(uint16Buffer));
    
}

- (id)initWithData: (NSData *)data{

    self = [super init];
    
    if(self){
    
        [self parseData:data];
    
    }
    
    return self;

}

- (void) parseData:(NSData*)bleFrameData{

    UInt8 *buffer = (UInt8 *)[bleFrameData bytes];
    
    self.type = [self bleBufferToUInt16:&buffer[TYPE_OFFSET]];
    
    self.length = [self bleBufferToUInt16:&buffer[LENGTH_OFFSET]];
    
    self.frameNumber = [self bleBufferToUInt16:&buffer[FRAME_OFFSET]];
    
    self.checkSum = [self bleBufferToUInt16:&buffer[CHECK_SUM_OFFSET]];
    
    self.data = [self bleBufferToUInt16:&buffer[DATA_OFFSET]];
    
}

- (void) detectCommand{
    
    if(self.type == INTERACTION_ONLINE) {
        
        NSLog(@"interacOnline");
        
        switch (self.data) {
                
            case SWIPE_UP:{
                
                NSLog(@"swipe up");
                
            }
                
                break;
                
            case SWIPE_DOWN:{
                
                NSLog(@"swide down");
                
            }
                
                break;
                
            case SWIPE_LEFT:{
            
                NSLog(@"swide left");
            
            }
                
                break;
                
            case SWIPE_RIGHT:{
            
                NSLog(@"swipe right");
                
            }
                
                break;
                
            case CLICK:{
            
                NSLog(@"click");
            
            }
                
                break;
                
            default:
                
                break;
        }
        
    }
    
}

- (NSData *)createCommand: (uint8)typeCommand
                     data: (NSData*)data{
    
    NSMutableData *command = [[NSMutableData alloc] init];

    switch (typeCommand) {
            
        case SET_TIME: {
            
            NSLog(@"SET_TIME" );
            
            uint16 type = SET_TIME;
            
            uint16 typeSwap = CFSwapInt16HostToBig(type);
            
            [command appendBytes:&typeSwap length:sizeof(typeSwap)];
            
        }
            
            break;
            
        case START_SESSION: {
            
            NSLog(@"START_SESSION" );
            
            uint16 type = START_SESSION;
            
            uint16 typeSwap = CFSwapInt16HostToBig(type);
            
            [command appendBytes:&typeSwap length:sizeof(typeSwap)];
            
        }
            
            break;
            
        case STOP_SESSION: {
            
            NSLog(@"STOP_SESSION" );
            
            uint16 type = STOP_SESSION;
            
            uint16 typeSwap = CFSwapInt16HostToBig(type);
            
            [command appendBytes:&typeSwap length:sizeof(typeSwap)];
            
        }
        
            break;
            
        case REQUEST_RESULT:
            
            break;
            
        default:
            
            break;
            
    }
    
    unsigned long sizeOfData = 0;
    
    if(data != nil){
        
        sizeOfData = [data length];
        
    }
    
    unsigned long sizeOfDataSwap = CFSwapInt16HostToBig(sizeOfData);
    
    [command appendBytes:&sizeOfDataSwap length:sizeof(sizeOfDataSwap)];
    
    uint16 frameNumber = 0;
    
    uint16 frameNumberSwap = CFSwapInt16HostToBig(frameNumber);
    
    [command appendBytes:&frameNumberSwap length:sizeof(frameNumberSwap)];
    
    uint16 checkSum = 0;
    
    uint16 checkSumSwap = CFSwapInt16HostToBig(checkSum);
    
    [command appendBytes:&checkSumSwap length:sizeof(checkSumSwap)];
    
    [command appendData:data];
    
    return command;
    

}

@end
