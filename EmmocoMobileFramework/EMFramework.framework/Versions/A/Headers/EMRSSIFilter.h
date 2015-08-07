//
//  EMRSSIFilter.h
//  EMFramework
//
//  Created by Dexter Weiss on 8/9/13.
//  Copyright (c) 2013 Emmoco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSignalStrengthFilter.h"

@interface EMRSSIFilter : NSObject <EMSignalStrengthFilter>

+(EMRSSIFilter *)filterWithInitialRSSI:(float)rssi;

@end
