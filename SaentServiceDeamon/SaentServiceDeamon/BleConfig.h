//
//  BleConfig.h
//  SaentServiceDeamon
//
//  Created by APAC Builder on 9/10/15.
//  Copyright (c) 2015 APAC Builder. All rights reserved.
//

#ifndef SaentServiceDeamon_BleConfig_h
#define SaentServiceDeamon_BleConfig_h

// TYPE OF COMMAND

const uint16 SET_TIME = 0x0001;

const uint16 START_SESSION = 0x0002;

const uint16 STOP_SESSION = 0x0003;

const uint16 REQUEST_RESULT = 0x0004;

const uint16 INTERACTION_ONLINE = 0x8000;

// FUNCTION CODE

const uint16 SWIPE_UP = 0x0000;

const uint16 SWIPE_DOWN = 0x0001;

const uint16 SWIPE_LEFT = 0x0002;

const uint16 SWIPE_RIGHT = 0x0003;

const uint16 CLICK = 0x0004;

#endif
