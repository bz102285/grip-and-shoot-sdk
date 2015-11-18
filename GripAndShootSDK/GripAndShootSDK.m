//
//  GripAndShootSDK.m
//  GripAndShootSDK
//
//  Created by Dexter Weiss on 4/26/14.
//  Copyright (c) 2014 Zeta Manufacturing. All rights reserved.
//

#import "GripAndShootSDK.h"
#import <EMFramework/EMFramework.h>

NSString * const GripAndShootErrorDomain = @"GripAndShootErrorDomain";

@import CoreBluetooth;

NSString * const GripAndShootSDKDidDiscoverGripNotificationName = @"GripAndShootSDKDidDiscoverGripNotificationName";
NSString * const GripAndShootDidConnectGripNotificationName = @"GripAndShootDidConnectGripNotificationName";
NSString * const GripAndShootGripUserInfoKey = @"GripAndShootGripUserInfoKey";

NSString * const GripDidStartZoomingInNotificationName = @"GripDidStartZoomingInNotificationName";
NSString * const GripDidStartZoomingOutNotificationName = @"GripDidStartZoomingOutNotificationName";
NSString * const GripDidStopZoomingInNotificationName = @"GripDidStopZoomingInNotificationName";
NSString * const GripDidStopZoomingOutNotificationName = @"GripDidStopZoomingOutNotificationName";
NSString * const GripDidCaptureNotificationName = @"GripDidCaptureNotificationName";

static NSString * const GripAndShootLastConnectedGripUserDefault = @"GripAndShootLastConnectedGripUserDefault";

@interface GripAndShootSDK ()

@property (nonatomic, getter = isScanning) BOOL scanning;

@end

@implementation GripAndShootSDK

static GripAndShootSDK *staticInstance = nil;

+(GripAndShootSDK *)sharedSDK {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        staticInstance = [GripAndShootSDK new];
    });
    return staticInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _availableGrips = [NSMutableArray new];
        
        [[EMConnectionListManager sharedManager] addObserver:self
                                                  forKeyPath:@"devices"
                                                     options:0
                                                     context:NULL];
        
        [[EMConnectionManager sharedManager] addObserver:self
                                              forKeyPath:@"connectionState"
                                                 options:0
                                                 context:NULL];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:kEMConnectionDidReceiveIndicatorNotificationName object:nil queue:[NSOperationQueue currentQueue] usingBlock:^(NSNotification *note) {
            [self indicatorReceived:note];
        }];
    }
    return self;
}

-(void)indicatorReceived:(NSNotification *)notification {
    id value = notification.userInfo[kEMIndicatorResourceKey];
    NSString *name = notification.userInfo[kEMIndicatorNameKey];
    
    if ([name isEqualToString:@"zoomInButton"]) {
        if ([value isEqualToString:@"PRESSED"]) {
            [self _startZoomingIn];
        }
        else {
            [self _stopZoomingIn];
        }
    }
    else if ([name isEqualToString:@"zoomOutButton"]) {
        if ([value isEqualToString:@"PRESSED"]) {
            [self _startZoomingOut];
        }
        else {
            [self _stopZoomingOut];
        }
    }
    else if ([name isEqualToString:@"pictureButton"]) {
        [self _capture];
    }
}

-(void)startScanningForGripsWithRate:(NSTimeInterval)scanRate {
    [[EMConnectionListManager sharedManager] setUpdateRate:scanRate];
    [[EMConnectionListManager sharedManager] startUpdating];
    self.scanning = YES;
}

-(void)stopScanningForGrips {
    [[EMConnectionListManager sharedManager] stopUpdating];
    [[EMConnectionListManager sharedManager] reset];
    [self setScanning:NO];
}

-(void)connectToGrip:(ZMGrip *)grip
    withSuccessBlock:(void(^)(void))successBlock
           failBlock:(void(^)(NSError *error))failBlock
{
    /*
     There is an existing bug in the firmware that causes a broken connection
     if the board is connected to immediately upon waking up.
     
     This dispatch guarantees we do not hit that particular issue.
     */
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        EMDeviceBasicDescription *description = [[EMConnectionListManager sharedManager] deviceBasicDescriptionForDeviceNamed:[grip name]];
        if (description == nil) {
            if (failBlock) {
                NSError *error = [NSError errorWithDomain:GripAndShootErrorDomain code:GripAndShootErrorCannotFindDevice userInfo:nil];
                failBlock(error);
            }
            return;
        }
        
        EMConnectionState state = [EMConnectionManager sharedManager].connectionState;
        if (state == EMConnectionStatePending || state == EMConnectionStateConnected || state == EMConnectionStatePendingForDefaultSchema) {
            if (failBlock) {
                NSError *error = [NSError errorWithDomain:GripAndShootErrorDomain code:GripAndShootErrorConnectionAlreadyPending userInfo:nil];
                failBlock(error);
            }
            return;
        }
        
        __weak typeof (self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [[EMConnectionManager sharedManager] connectDevice:description onSuccess:^{
                weakSelf.connectedGrip = grip;
                [[NSUserDefaults standardUserDefaults] setObject:description.name forKey:GripAndShootLastConnectedGripUserDefault];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [[NSNotificationCenter defaultCenter] postNotificationName:GripAndShootDidConnectGripNotificationName object:weakSelf userInfo:@{GripAndShootGripUserInfoKey : grip}];
                if (successBlock) {
                    successBlock();
                }
                
            } onFail:^(NSError *error) {
                weakSelf.connectedGrip = nil;
                if (failBlock) {
                    failBlock(error);
                }
            }];
        });
    });
}

-(void)disconnectGripWithSuccessBlock:(void(^)(void))successBlock failBlock:(void(^)(NSError *error))failBlock {
    __weak typeof (self) weakSelf = self;
    [[EMConnectionManager sharedManager] disconnectWithSuccess:^{
        weakSelf.connectedGrip = nil;
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
    if ([EMConnectionManager sharedManager].connectedDevice == nil) {
        self.connectedGrip = nil;
    }
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
            [self _connectionStateDidChange:[EMConnectionManager sharedManager].connectionState];
        }
    }
}

- (void)_connectionStateDidChange:(EMConnectionState)state {
    switch (state) {
        case EMConnectionStateDisconnected:
        case EMConnectionStateDisrupted:
        case EMConnectionStateTimeout:
        case EMConnectionStateSchemaNotFound:
        case EMConnectionStateInvalidSchemaHash:
            self.connectedGrip = nil;
            break;
        case EMConnectionStateConnected:
        {
            NSString *connectedGripName = [EMConnectionManager sharedManager].connectedDevice.name;
            ZMGrip *grip = [ZMGrip new];
            grip.name = connectedGripName;
            self.connectedGrip = grip;
            break;
        }
        default:
            break;
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
