#import <Foundation/Foundation.h>
#import "EMConnectionType.h"

#if TARGET_OS_IPHONE
    #import <CoreBluetooth/CoreBluetooth.h>
#else
    #import <IOBluetooth/IOBluetooth.h>
#endif



/**
 * EMBluethoothLowEnergyConnectionType is a concrete EMConnectionType for Bluetooth Low Energy.
 *
 * If you want the framework to interact with Bluetooth Low Energy devices, add an instance of this class to EMConnectionListManager via the -addConnectionTypeToUpdates: method.
 */

@interface EMBluetoothLowEnergyConnectionType : NSObject <EMConnectionType, CBCentralManagerDelegate, CBPeripheralDelegate> {

}

@property (nonatomic) NSTimeInterval scanResetTime;

/**
 * By default, EMBluetoothLowEnergyConnectionType will 'discover' devices that have a schema hash matching a schema in your application bundle.
 * Set this flag to 'YES' for an instance of this class to discover all Emmoco BLE devices.
 * NOTE: Most applications should not have this enabled.
 */
@property (nonatomic) BOOL discoversAllEmmocoBLEDevices;

+(CBUUID *)emmocoServiceUUID;
+(CBUUID *)emmocov12ServiceUUID;

@end
