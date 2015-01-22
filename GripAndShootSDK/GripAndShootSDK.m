//
//  GripAndShootSDK.m
//  GripAndShootSDK
//
//  Created by Dexter Weiss on 4/26/14.
//  Copyright (c) 2014 Zeta Manufacturing. All rights reserved.
//

#import "GripAndShootSDK.h"
#import "EMFramework.h"

@import CoreBluetooth;

NSString * const GripAndShootSDKDidDiscoverGripNotificationName = @"GripAndShootSDKDidDiscoverGripNotificationName";
NSString * const GripAndShootGripUserInfoKey = @"GripAndShootGripUserInfoKey";

NSString * const GripDidStartZoomingInNotificationName = @"GripDidStartZoomingInNotificationName";
NSString * const GripDidStartZoomingOutNotificationName = @"GripDidStartZoomingOutNotificationName";
NSString * const GripDidStopZoomingInNotificationName = @"GripDidStopZoomingInNotificationName";
NSString * const GripDidStopZoomingOutNotificationName = @"GripDidStopZoomingOutNotificationName";
NSString * const GripDidCaptureNotificationName = @"GripDidCaptureNotificationName";

@interface GripAndShootSDK ()

@property (nonatomic, getter = isScanning) BOOL scanning;

@end

@implementation GripAndShootSDK

static GripAndShootSDK *staticInstance = nil;

+(GripAndShootSDK *)sharedSDK {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        staticInstance = [[GripAndShootSDK alloc] init];
        staticInstance->_availableGrips = [NSMutableArray array];
        
        [[EMConnectionListManager sharedManager] addObserver:staticInstance forKeyPath:@"devices" options:0 context:NULL];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:kEMConnectionDidReceiveIndicatorNotificationName object:nil queue:[NSOperationQueue currentQueue] usingBlock:^(NSNotification *note) {
            [staticInstance indicatorReceived:note];
        }];
        
        [[EMConnectionManager sharedManager] addObserver:staticInstance forKeyPath:@"connectionState" options:0 context:NULL];
        
        if ([[EMConnectionListManager sharedManager] isBluetoothAvailable]) {
            [staticInstance setStatus:GripAndShootStatusPoweredOn];
        }
        else {
            [staticInstance setStatus:GripAndShootStatusBluetoothUnavailable];
        }
    });
    return staticInstance;
}

-(void)indicatorReceived:(NSNotification *)notification {
    id value = [[notification userInfo] objectForKey:kEMIndicatorResourceKey];
    NSString *name = [[notification userInfo] objectForKey:kEMIndicatorNameKey];
    if ([name isEqualToString:@"zoomInButton"]) {
        if ([value isEqualToString:@"PRESSED"]) {
            [staticInstance _startZoomingIn];
        }
        else {
            [staticInstance _stopZoomingIn];
        }
    }
    else if ([name isEqualToString:@"zoomOutButton"]) {
        if ([value isEqualToString:@"PRESSED"]) {
            [staticInstance _startZoomingOut];
        }
        else {
            [staticInstance _stopZoomingOut];
        }
    }
    else if ([name isEqualToString:@"pictureButton"]) {
        [staticInstance _capture];
    }
}

-(void)startScanningForGripsWithRate:(NSTimeInterval)scanRate {
    [[EMConnectionListManager sharedManager] setUpdateRate:scanRate];
    [[EMConnectionListManager sharedManager] startUpdating];
    [self setScanning:YES];
}

-(void)stopScanningForGrips {
    [[EMConnectionListManager sharedManager] stopUpdating];
    [[EMConnectionListManager sharedManager] reset];
    [self setScanning:NO];
}

-(void)connectToGrip:(ZMGrip *)grip withSuccessBlock:(void(^)(void))successBlock failBlock:(void(^)(NSError *error))failBlock {
    [self setConnectedGrip:grip];
    EMDeviceBasicDescription *description = [[EMConnectionListManager sharedManager] deviceBasicDescriptionForDeviceNamed:[grip name]];
    [[EMConnectionManager sharedManager] connectDevice:description onSuccess:^{
        if (successBlock) {
            successBlock();
        }
    } onFail:^(NSError *error) {
        [self setConnectedGrip:nil];
        if (failBlock) {
            failBlock(error);
        }
    }];
}

-(void)disconnectGripWithSuccessBlock:(void(^)(void))successBlock failBlock:(void(^)(NSError *error))failBlock {
    [[EMConnectionManager sharedManager] disconnectWithSuccess:^{
        [self setConnectedGrip:nil];
        if (successBlock) {
            successBlock();
        }
    } onFail:^(NSError *error) {
        if (failBlock) {
            failBlock(error);
        }
    }];
}

#pragma mark - KVO

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == [EMConnectionListManager sharedManager]) {
        if ([keyPath isEqualToString:@"devices"]) {
            NSMutableArray *grips = [NSMutableArray array];
            for (EMDeviceBasicDescription *device in [[EMConnectionListManager sharedManager] devices]) {
                ZMGrip *grip = [ZMGrip new];
                [grip setName:[device name]];
                
                if (![[self availableGrips] containsObject:grip]) {
                    [self _discoveredGrip:grip];
                }
                [grips addObject:grip];
            }
            [self setAvailableGrips:grips];
        }
    }
    else if (object == [EMConnectionManager sharedManager]) {
        if ([keyPath isEqualToString:@"connectionState"]) {
            if ([EMConnectionManager sharedManager].connectionState == EMConnectionStateDisconnected) {
                self.connectedGrip = nil;
            }
        }
    }
}

-(void)_discoveredGrip:(ZMGrip *)grip {
    [[NSNotificationCenter defaultCenter] postNotificationName:GripAndShootSDKDidDiscoverGripNotificationName object:self userInfo:@{GripAndShootGripUserInfoKey : grip}];
}

#pragma mark - Grip Functions

-(void)_startZoomingIn {
    [[NSNotificationCenter defaultCenter] postNotificationName:GripDidStartZoomingInNotificationName object:self];
}

-(void)_stopZoomingIn {
    [[NSNotificationCenter defaultCenter] postNotificationName:GripDidStopZoomingInNotificationName object:self];
}

-(void)_startZoomingOut {
    [[NSNotificationCenter defaultCenter] postNotificationName:GripDidStartZoomingOutNotificationName object:self];
}

-(void)_stopZoomingOut {
    [[NSNotificationCenter defaultCenter] postNotificationName:GripDidStopZoomingOutNotificationName object:self];
}

-(void)_capture {
    [[NSNotificationCenter defaultCenter] postNotificationName:GripDidCaptureNotificationName object:self];
}

@end
