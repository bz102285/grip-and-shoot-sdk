#import "EMConnectionType.h"
#import <Foundation/Foundation.h>

/**
 * kEMConnectionManagerDidStartUpdating is the name of a notification that is posted when the list manager begins updating, or scanning, for available devices
 */

extern NSString * const kEMConnectionManagerDidStartUpdating;

/**
 * kEMConnectionManagerDidStopUpdating is the name of a notification that is posted when the list manager stops updating, or scanning, for available devices
 */

extern NSString * const kEMConnectionManagerDidStopUpdating;

/**
 * EMConnectionListManager is a singleton class used for viewing a list of devices available for interaction.
 */
@interface EMConnectionListManager : NSObject <EMConnectionTypeScannerDelegate>

/**
 * @property devices
 * A list of devices that has been discovered as available by the connection list manager
 */
@property (nonatomic, strong, readonly) NSArray *devices;

/**
 * @property filterPredicate
 * A filter that allows only devices conforming to the predicate to be visible
 */
@property (nonatomic, strong) NSPredicate *filterPredicate;

/**
 * @property updating
 * A boolean value indicating whether or not the connection list manager is actively updating the devices list
 */
@property (nonatomic, getter = isUpdating, readonly) BOOL updating;

/**
 * @property updateRate
 * updateRate determines the scan frequency for discovering devices
 */
@property (nonatomic) NSTimeInterval updateRate;


/**
 * @param automaticallyConnectsToLastDevice
 * A boolean value indicating whether or not the connection list manager should automatically connect to the last device it was connected to if it encounters it in a scan.
 */
@property (nonatomic) BOOL automaticallyConnectsToLastDevice;


/**
 * Use the +sharedManager to get the singleton, shared instance of EMConnectionListManager
 */
+(EMConnectionListManager *)sharedManager;

/**
 * Retrieve a device description for a given unique identifier
 * @param name The name of the device
 */

-(EMDeviceBasicDescription *)deviceBasicDescriptionForDeviceNamed:(NSString *)name;

/**
 * Tells the connection list manager to begin actively looking for devices to interact with.
 */
-(void)startUpdating;

/**
 * Tells the connection list manager to stop looking for devices to interact with.
 */
-(void)stopUpdating;

/**
 * Manually clears out all devices on the connection list manager.
 */
-(void)reset;

/**
 * Detect if Bluetooth is available
 */
-(BOOL)isBluetoothAvailable;

/**
 * Add your own connection type outside of bluetooth low energy
 */
-(void)addConnectionTypeToUpdates:(id<EMConnectionType>)connectionType;

/**
 * Remove your own connection type outside of bluetooth low energy
 */
-(void)removeConnectionToFromUpdates:(id<EMConnectionType>)connectionType;

@end
