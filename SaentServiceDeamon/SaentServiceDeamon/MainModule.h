//
//  MainModule.h
//  SaentServiceDeamon
//
//  Created by APAC Builder on 9/14/15.
//  Copyright (c) 2015 APAC Builder. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BaseModule.h"

#import "CentralClient.h"

#import "DOServer.h"

@interface MainModule : BaseModule<CentralClientDelegate, DOServerDelegate>

@property(nonatomic, strong) CentralClient* bleModule;

@property(nonatomic, strong) DOServer* doModule;

@property(nonatomic, weak) id<CentralClientDelegate> bleModuleDelagate;

@property(nonatomic, weak) id<DOServerDelegate> doModuleDelegate;

- (id)initWith: (CentralClient*)bleModule
        doModule: (DOServer*)doModule;

@end
