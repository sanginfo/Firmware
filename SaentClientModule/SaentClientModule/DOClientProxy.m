//
//  DOClientProxy.m
//  SaentClientModule
//
//  Created by APAC Builder on 9/17/15.
//  Copyright (c) 2015 APAC Builder. All rights reserved.
//

#import "DOClientProxy.h"

@implementation DOClientProxy

#pragma mark - Using to receive response from MainModule

- (void)discoverPeripheralsResult: (NSMutableArray*)listPeripherals{
    
    [self.delegate discoverPeripheralsDelegate:listPeripherals];
    
}

- (void)clientProxyReceiveResult: (UInt32)code
                         message: (NSString*)message
                       exception: (NSException*)exception{

    [self.delegate clientProxyReceiveDelegate:code
                                      message:message
                                    exception:exception];

}


@end
