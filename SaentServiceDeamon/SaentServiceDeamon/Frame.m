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

static Frame *instance = nil;

#pragma pack(1)
typedef struct{
    UInt16 type;
    UInt16 length;
    UInt16 frame;
    UInt16 checksum;
    Byte data[1];
} SaentBLECmd;
#pragma options align = reset


@implementation Frame


+ (id)getSingleton{

    @synchronized(self){
    
        if(instance == nil){
        
            instance = [[Frame alloc] init];
            
            instance.wFrameNumber = 0;
        
        }
        
        return instance;
    
    }

}

- (void) parseData:(NSData*)bleFrameData{
    SaentBLECmd* cmd = (SaentBLECmd*)[bleFrameData bytes];
    
    self.type = CFSwapInt16LittleToHost(cmd->type);
    
    self.length = CFSwapInt16LittleToHost(cmd->length);
    
    self.frameNumber = CFSwapInt16LittleToHost(cmd->frame);
    
    self.checkSum = CFSwapInt16LittleToHost(cmd->checksum);
    
    self.data = CFSwapInt16LittleToHost(*((UInt16*)cmd->data));
    
}

- (NSString*) detectCommand{
    
    NSMutableString* command = [[NSMutableString alloc] init];
    
    if(self.type == INTERACTION_ONLINE) {
        
        NSLog(@"interacOnline");
        
        if(self.data == SWIPE_UP){
        
            [command appendFormat:@"SWIPE UP"];
        
        }
        
        if(self.data == SWIPE_DOWN){
        
            [command appendFormat:@"SWIPE DOWN"];
        
        }
        
        if(self.data == SWIPE_LEFT){
        
            [command appendFormat:@"SWIPE LEFT"];
        
        }
        
        if(self.data == SWIPE_RIGHT){
        
            [command appendFormat:@"SWIPE RIGHT"];
        
        }
        
        if(self.data == CLICK){
        
            [command appendFormat:@"CLICK"];
        
        }
        
    }
    
    return (NSString*)command;
    
}

- (NSData *)createCommand: (uint8)typeCommand
                     data: (NSData*)data{
    
    NSMutableData *command = [[NSMutableData alloc] init];
    
    if(typeCommand == SET_TIME){
    
        NSLog(@"Frame: CreateCommand: SET_TIME" );
        
        uint16 type = SET_TIME;
        
        uint16 typeSwap = CFSwapInt16HostToBig(type);
        
        [command appendBytes:&typeSwap length:sizeof(typeSwap)];
    
    }
    
    if(typeCommand == START_SESSION){
    
        NSLog(@"Frame: CreateCommand: START_SESSION" );
        
        uint16 type = START_SESSION;
        
        uint16 typeSwap = CFSwapInt16HostToBig(type);
        
        [command appendBytes:&typeSwap length:sizeof(typeSwap)];
    
    }
    
    if(typeCommand == STOP_SESSION){
    
        NSLog(@"Frame: CreateCommand: STOP_SESSION" );
        
        uint16 type = STOP_SESSION;
        
        uint16 typeSwap = CFSwapInt16HostToBig(type);
        
        [command appendBytes:&typeSwap length:sizeof(typeSwap)];
    
    }
    
    if(typeCommand == REQUEST_RESULT){
    
        NSLog(@"Frame: CreateCommand: NOT IMPLEMENT" );
    
    }
    
    unsigned long sizeOfData = 0;
    
    if(data != nil){
        
        sizeOfData = [data length];
        
    }
    
    unsigned long sizeOfDataSwap = CFSwapInt16HostToBig(sizeOfData);
    
    [command appendBytes:&sizeOfDataSwap length:sizeof(sizeOfDataSwap)];
    
    uint16 frameNumber = self.wFrameNumber;
    
    self.wFrameNumber++;
    
    uint16 frameNumberSwap = CFSwapInt16HostToBig(frameNumber);
    
    [command appendBytes:&frameNumberSwap length:sizeof(frameNumberSwap)];
    
    uint16 checkSum = 0;
    
    uint16 checkSumSwap = CFSwapInt16HostToBig(checkSum);
    
    [command appendBytes:&checkSumSwap length:sizeof(checkSumSwap)];
    
    if(data != nil){
        
        [command appendData:data];
        
    }
    
    return command;
    

}

@end
