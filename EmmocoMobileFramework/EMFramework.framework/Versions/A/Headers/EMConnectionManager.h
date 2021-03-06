#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "EMConnection.h"
#import "EMSchema.h"
#import "EMConnectionType.h"

#ifndef CB_EXTERN_CLASS
#warning "You must include CoreBluetooth in project to use Em-Framework"
#endif

/**
 * A constant for NSUserDefaults that contains the name of the last connected device, if there is one
 */

extern NSString * const kLastConnectedDevice;

extern NSString * const kEMConnectionManagerDidUpdateConnectionStateNotificationName;

/**
 *  Various types of connection errors.
 */

typedef enum {
    EMConnectionManagerErrorNoSchemaAvailable,
    EMConnectionManagerErrorCouldNotDisconnect,
    EMConnectionManagerErrorDeviceNotAvailable,
    EMConnectionManagerErrorDeviceAlreadyConnected
} EMConnectionManagerError;

extern NSString * const kEMConnectionManagerErrorDomain;

@class EMTargetDevice;
@class EMConnection;

/**
 * EMConnectionManager is a singleton class for managing a connection with a physical or mock device.
 */

@interface EMConnectionManager : NSObject <EMConnectionDelegate>

@property (nonatomic) EMConnectionState connectionState;

@property (nonatomic, strong) NSURL *defaultSchemaURL;

/*
 * Set this property if you are not loading system.json out of EMResources.bundle
 *
 * If in doubt, you do not need to set this property.
 */
@property (nonatomic, strong) NSBundle *systemSchemaBundle;


/**
 @property backgroundUpdatesEnabled
 @description If you set this flag to "YES", the connection manager has the ability to persist while running in the background.  By default, the connection manager severs connections when entering the background.
 */
@property (nonatomic) BOOL backgroundUpdatesEnabled;

/**
 *  Use the +sharedManager class method to access the application-wide singleton instance of EMConnectionManager.
 *  Note: Accessing the connection manager in any way other is not recommended.
 */

+(EMConnectionManager *)sharedManager;

/**
 * If using a bundle other than the default EMResources.bundle, use this method to set the bundle name
 *
 * @param bundleName The name of the bundle to use (excluding ".bundle")
 * @return BOOL based on whether a bundle matching the supplied bundleName can be found. If NO, systemSchemaBundle remains set to the default
 */

-(BOOL)setBundleName:(NSString *)bundleName;

/**
 * YES if a device connection isn't active or pending.  NO otherwise.
 */
-(BOOL)canConnect;

/**
 *  Tells the connection manager to connect to a specific device.
 *
 *  @param device An instance of EMDeviceBasicDescription the connection manager should connect to
 *  @param successBlock The block to run after a successful connection
 *  @param failBlock The block to run if the connectino fails
 *  @description The implementation of this method calls connectDevice:timeoutInterval:onSuccess:onFail: with a default time interval of 10 seconds
 */

-(void)connectDevice:(EMDeviceBasicDescription *)device onSuccess:(void(^)(void))successBlock onFail:(void(^)(NSError *error))failBlock;

/**
 *  Tells the connection manager to connect to a specific device.
 *
 *  @param device An instance of EMDeviceBasicDescription the connection manager should connect to
 *  @param timeout The time the connection manager should allow for a successful connection.  After the specified time interval passes, the fail block will be called.
 *  @param successBlock The block to run after a successful connection
 *  @param failBlock The block to run if the connection fails
 *  @description The implementation of this method calls connectDevice:timeoutInterval:onSuccess:onFail: with a default time interval of 10 seconds
 */
-(void)connectDevice:(EMDeviceBasicDescription *)device timeoutInterval:(NSTimeInterval)timeout onSuccess:(void(^)(void))successBlock onFail:(void(^)(NSError *error))failBlock;

/**
 *  Tells the connection manager to disconnect from a specific device
 *
 *  @param successBlock The block to run after a successful disconnection
 *  @param failBlock The block to run if the disconnection fails.
 */
-(void)disconnectWithSuccess:(void(^)(void))successBlock onFail:(void(^)(NSError *error))failBlock;

/**
 *  Reads a resource from a connected device
 *
 *  @param resourceName The name of the resource to read.  This is the name of the resource in the device's schema.
 *  @param successBlock The block to call when a read occurs successfully.  Connection manager will call this block with the value read.
 *  @param failBlock The block to call when a read fails.
 */
-(void)readResource:(NSString *)resourceName onSuccess:(void(^)(id readValue))successBlock onFail:(void(^)(NSError *error))failBlock;

/**
 *  Writes a value to a resource on a connected device
 *
 *  @param resourceValue The value to write to the resource.  This should be an instance of NSString, NSData, NSArray, NSNumber, or NSDictionary
 *  @param resource The name of the resource for writing.  This is the name of the resource in the schema.
 *  @param successBlock The block to call when the write occurs successfully.
 *  @param failBlock The block to call when the write fails.
 */
-(void)writeValue:(id)resourceValue toResource:(NSString *)resource onSuccess:(void(^)(void))successBlock onFail:(void(^)(NSError *error))failBlock;

/**
 *  Returns an array of EMDeviceBasicDescription's for the device that is actively connected
 */
-(EMDeviceBasicDescription *)connectedDevice;

/**
 *  Returns a version of the the schema hash from a connected device's firmware as it appears on em-hub
 */
-(NSString *)schemaHashForConnectedDevice;

/**
 *  Tells the connection manager where it should look for schemas other than the NSBundle's mainBundle
 *
 * @param path The path for the directory in which to search
 */
-(void)addSchemaSearchForFilesInDirectory:(NSString *)path;

/**
 * Tells the connection manager to no longer look in the specified path for schemas
 *
 * @param path The path to no longer search
 * @description Note: This method will never ignore the current bundle's mainBundle
 */
-(void)removeSchemaSearchForFilesInDirectory:(NSString *)path;

/**
 * Forces the connection manager to connect to a device with the default schema
 * @param device The device for the forced connection
 * @description Use this method with extreme caution.  Many undefined behaviors can come from using this method with a schema that isn't an exact match for the specified device.  EMConnectionManager uses this method internally.  It is very rare that you will need to call this method directly.
 */
-(void)forceConnectionWithDefaultSchema:(EMDeviceBasicDescription *)device;

/**
 *  Tells EMConnectionManager to update its internal cache of schemas used for connection.
 *  @description EMConnectionManager uses this method internally.  It is very rare taht you will need to call this method directly.
 */
-(void)updateInternalSchemaCache;

/**
 * Gives the schema name in the application bundle for a given hash string
 * @param hashString A full or partial schema hash string
 * @description This method takes either a full hash or partial hash.  If any schema begins with 'hash string', the file name in the bundle is returned.  Returns nil if no matching schema was found in the bundle.
 * If one or more schemas share 'hashString' at the beginning of their hash, the first path will be returned.
 */
-(NSString *)schemaFileNameForHashString:(NSString *)hashString;

/**
 *  Gets the schema for the connected device.
 *  @description   Returns nil if no device is connected.
 */

-(EMSchema *)schemaForConnectedDevice;

/**
 *  Gets the embedded system protocol level from the schema used to connect to the device
 *  @description This call does not send a message down to the board - the protocol level is pulled directly from the schema that was used to connect to the device.
 */

-(NSNumber *)embeddedSystemProtocolLevel;

@end
