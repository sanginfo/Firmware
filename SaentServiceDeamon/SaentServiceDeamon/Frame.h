//
//  Frame.h
//  SaentServiceDeamon
//
//  Created by APAC Builder on 9/8/15.
//  Copyright (c) 2015 APAC Builder. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BleConfig.h"

@interface Frame : NSObject

@property(nonatomic) UInt16 type, length, frameNumber, checkSum, data;

//@property(nonatomic) NSData *data;

- (id)initWithData: (NSData *)frameData;

- (void) detectCommand;

- (NSData *)createCommand: (uint8)typeCommand
                   data: (NSData *)data;


@end
