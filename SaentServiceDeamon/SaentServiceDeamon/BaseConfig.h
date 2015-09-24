//
//  BaseConfig.h
//  SaentServiceDeamon
//
//  Created by APAC Builder on 9/11/15.
//  Copyright (c) 2015 APAC Builder. All rights reserved.
//

#import <Foundation/Foundation.h>

//NSString* const CONFIG_FILE_NAME = @"config";

@interface BaseConfig : NSObject

@property(nonatomic, strong) NSXMLDocument* xmlDoc;

- (BOOL)saveConfig:(NSString*)key
             value: (NSString*)value;

- (BOOL)getConfig: (NSString **)key
                  value: (NSString **)value;

- (BOOL)saveDeviceID: (NSString*)value;

- (NSString*)getDeviceID;

@end
