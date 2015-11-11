//
//  GripAndShootSDK.h
//  GripAndShootSDK
//
//  Created by Dexter Weiss on 4/26/14.
//  Copyright (c) 2014 Zeta Manufacturing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZMGrip.h"

#pragma mark - Notifications

/*
 Notifications with name "GripAndShootSDKDidDiscoverGripNotificationName" are sent when a new grip is discovered.
 Check the "GripAndShootGripUserInfoKey" key in the notification's -userInfo to get the grip
 */

extern NSString * const GripAndShootSDKDidDiscoverGripNotificationName;
extern NSString * const GripAndShootDidConnectGripNotificationName;
extern NSString * const GripAndShootGripUserInfoKey;

/*
 When a grip is connected, you will get these notifications when buttons are pressed and released.
 
 GripDidStartZoomingInNotificationName - the user pressed the zoom in button
 GripDidStartZoomingOutNotificationName - the user pressed the zoom out button
 GripDidStopZoomingInNotificationName - the user released the zoom in button
 GripDidStopZoomingOutNotificationName - the user released the zoom out button
 GripDidCaptureNotificationName - the user pressed the photo capture button
 */
extern NSString * const GripDidStartZoomingInNotificationName;
extern NSString * const GripDidStartZoomingOutNotificationName;
extern NSString * const GripDidStopZoomingInNotificationName;
extern NSString * const GripDidStopZoomingOutNotificationName;
extern NSString * const GripDidCaptureNotificationName;

@interface GripAndShootSDK : NSObject

/*
 @property availableGrips
 
 This property holds all grips that are availble for connection
 You can observe this property to get real-time updates on available devices
 */
@property (nonatomic, strong) NSMutableArray *availableGrips;

/*
 @property connectedGrip
 
 The currently connected grip.  nil if no grip is connected.
 */

@property (nonatomic, strong) ZMGrip *connectedGrip;

/*
 Get the shared SDK instance
 */
+(GripAndShootSDK *)sharedSDK;

/*
 Start scanning for available grips.
 @arg scanRate The frequency the SDK should scan.  This affects battery life of the device.
 */
-(void)startScanningForGripsWithRate:(NSTimeInterval)scanRate;

/*
 Stop scanning for grips
 */
-(void)stopScanningForGrips;

/*
 Find out if the SDK is currently scanning for grips
 */
-(BOOL)isScanning;

/*
 Connect to a grip
 */
-(void)connectToGrip:(ZMGrip *)grip
    withSuccessBlock:(void(^)(void))successBlock
           failBlock:(void(^)(NSError *error))failBlock;

/*
 Disconnect from a grip
 */
-(void)disconnectGripWithSuccessBlock:(void(^)(void))successBlock
                            failBlock:(void(^)(NSError *error))failBlock;

@end
