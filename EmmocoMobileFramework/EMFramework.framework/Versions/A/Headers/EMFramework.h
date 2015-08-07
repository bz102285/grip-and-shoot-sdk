//
//  EMFramework.h
//  Emmoco
//
//  Created by bob frankel on 8/22/11.
//  Copyright 2011 Emmoco, Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EMFramework/EMTypes.h>
#import <EMFramework/EMConnectionManager.h>
#import <EMFramework/EMConnectionListManager.h>
#import <EMFramework/EMConnection.h>
#import <EMFramework/EMBluetoothLowEnergyConnectionType.h>
#import <EMFramework/EMSchema.h>
#import <EMFramework/EMResourceValue.h>
#import <EMFramework/EMRSSIFilter.h>
#import <EMFramework/EMSerialPacket.h>
#import <EMFramework/EMChecksum.h>
#import <EMFramework/EMConnectionType.h>
#import <EMFramework/EMDeviceBasicDescription.h>
#import <EMFramework/EMSignalStrengthFilter.h>

#define EMFrameworkProtocol_11

#define EMMinFramework @"12"
#define EMMaxFramework @"13"

#define SIGNAL_STRENGTH_UNAVAILABLE FLT_MIN

#ifdef DEBUG
#define EMLog(format, ...) NSLog(@"<%@:(%d)> %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(format), ##__VA_ARGS__])
#else
#define EMLog(format, ...)
#endif