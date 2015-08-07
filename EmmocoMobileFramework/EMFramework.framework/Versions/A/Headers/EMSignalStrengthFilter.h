//
//  EMSignalStrengthFilter.h
//  EMFramework
//
//  Created by Dexter Weiss on 8/9/13.
//  Copyright (c) 2013 Emmoco. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol EMSignalStrengthFilter <NSObject>

-(id)initWithInitialSignalStrengthValue:(float)signalStrengthValue;
-(float)addSignalStrengthValue:(float)signalStrengthValue;

@end
