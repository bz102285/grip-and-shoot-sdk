#import <Foundation/Foundation.h>
#import "EMSchema.h"
#import "EMDeviceBasicDescription.h"
#import "EMResourceValue.h"
#import "EMSignalStrengthFilter.h"

/**
 * EMTargetDeviceHandler is implemented by classes interested in manageing connections to devices.  By default, this will be the shared instance of EMConnectionManager.
 */
@protocol EMDeviceDelegate <NSObject>
- (void)extendConnectTimeout;
- (void)postIndicatorForResource:(EMResourceValue *)indicator;
- (void)operationDone:(int)status;
@end


#pragma  mark - EMConnectionTypeScannerDelegate Declaration

/**
 * These methods are sen tto the connection delegate to inform it of devices that come available or go offline.
 */

@protocol EMConnectionTypeScannerDelegate <NSObject>

/**
 * Tells the delegate a device was found.
 */

-(void)deviceScanner:(id)scanner didFindDevice:(EMDeviceBasicDescription *)device;

/**
 * Tells the delegate a device was lost.
 */
-(void)deviceScanner:(id)scanner didLoseDevice:(EMDeviceBasicDescription *)device;


/**
 * Updates the data for a device description
 */
-(void)deviceScanner:(id)scanner didUpdateDevice:(EMDeviceBasicDescription *)device;

@end

#pragma mark - EMConnectionType Declaration

/**
 * Abstracts a given protocol for connecting to devices.
 */

@protocol EMConnectionType <NSObject>

/**
 * The delegate for scanning
 */
@property (nonatomic, weak) id<EMConnectionTypeScannerDelegate> scanDelegate;

/**
 * The delegate for connection communication
 */
@property (nonatomic, weak) id<EMDeviceDelegate> connectionDelegate;

/**
 * The schema for connection
 */
@property (nonatomic, weak) EMSchema *schema;

/**
 * The last read resource value from the device
 */
@property (nonatomic, strong) EMResourceValue *lastReadValue;

/**
 * A boolean indicating whether or not there is a connection with a device.
 */
@property (nonatomic, readonly, getter = isConnected) BOOL connected;

/**
 * The class to use for filtering, or smoothin, signal strength values
 */
@property (nonatomic, strong) Class<EMSignalStrengthFilter> signalStrengthFilterClass;

/**
 * The type of device - this can be set to anything and retreived for printing or examining.
 */
-(NSString *)deviceType;

/**
 * Tells the connection to start looking for devices of its type.
 */
-(void)startUpdating;

/**
 * Tells the connection to stop looking for devices of its type.
 */
-(void)stopUpdating;

/**
 * Returns whether or not there is a connection with a device.
 */
-(BOOL)isConnected;

/**
 * disconnects the current device.
 *
 */
-(void)disconnect;

/**
 * Establishes a connection with a device
 */
-(void)connectToDevice:(EMDeviceBasicDescription *)device connectionDelegate:(id<EMDeviceDelegate>)connDelegate;


/**
 * YES if available on the current device, NO if unavailable.
 */
-(BOOL)isAvailable;

/**
 * Fetches a resource.  Can be retrieved in "lastReadValue"
 */
-(void)fetch:(id)resourceValue;

/**
 * Fetches a system resource.  Can be retrieved in "lastReadValue".
 */
- (void)fetchSystemResource:(id)resourceValue;

/**
 * writes a value to a device.
 */
-(void)store:(id)resourceValue;
@end

