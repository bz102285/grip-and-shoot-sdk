//
//  EMFramework.h
//  Emmoco
//
//  Created by bob frankel on 8/22/11.
//  Copyright 2011 Emmoco, Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMConnectionManager.h"
#import "EMConnectionListManager.h"
#import "EMConnection.h"
#import "EMBluetoothLowEnergyConnectionType.h"
#import "EMSchema.h"
#import "EMResourceValue.h"

#define EMFrameworkProtocol_11

#define EMMinFramework @"12"
#define EMMaxFramework @"13"

#define SIGNAL_STRENGTH_UNAVAILABLE FLT_MIN

#ifdef DEBUG
#define EMLog(format, ...) NSLog(@"<%@:(%d)> %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(format), ##__VA_ARGS__])
#else
#define EMLog(format, ...)
#endif