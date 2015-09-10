//
//  CommonProtocol.h
//  SaentServiceDeamon
//
//  Created by APAC Builder on 9/8/15.
//  Copyright (c) 2015 APAC Builder. All rights reserved.
//

#ifndef SaentServiceDeamon_CommonProtocol_h
#define SaentServiceDeamon_CommonProtocol_h

@protocol CommonProtocol <NSObject>

- (void)setTime: sessionDuration;

- (void)startSession;

- (void)stopSession;

- (void)requestResult;

@end

#endif
