//
//  ZMGrip.m
//  GripAndShootSDK
//
//  Created by Dexter Weiss on 4/26/14.
//  Copyright (c) 2014 Zeta Manufacturing. All rights reserved.
//

#import "ZMGrip.h"

@implementation ZMGrip

-(BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[self class]]) {
        return [[object name] isEqualToString:[self name]];
    }
    return NO;
}

@end
