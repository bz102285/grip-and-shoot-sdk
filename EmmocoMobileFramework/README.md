# Introduction

## What is the Emmoco Mobile Framework?

	The Emmoco Mobile Framework allows you to control any Emmoco-powered embedded system with your phone. The framework exposes a simple interface, abstracting Apple’s CoreBluetooth.framework, to facilitate rapid prototyping and development.

## Why not just use Core Bluetooth?

	Getting data from an embedded system to a mobile device is no small task, Bluetooth quirks aside. There are bit-alignment issues, data interpretation issues, and a multitude of failure scenarios that must be handled. You must also work closely with the embedded system developer to define the communication contract.

	By using Emmoco’s ecosystem, all of these problems are resolved for you. You can spend 0% of your time worrying about how to get data to and from the embedded system and 100% of your time building a great mobile app.

## Schemas - The contract between you and the embedded system

	All communication between a phone and an embedded system happens according to a communication contract, or *schema*. Here is an example schema:

	version = "1.0.0"
	description = "starter application" 
	schema MyApp {
		uint8 myFavoriteNumber
	}

	You can see the embedded system has a single resource, * myFavoriteNumber*. It is a one-byte unsigned integer.
On http://em-hub.com, you can download the “Mobile Schema” for any schema, which is a JSON file.

## Adding the Mobile Framework to your iOS project

### Download the mobile framework

	You can download the latest version of the mobile framework from http://em-hub.com.

### Library dependencies

	Add the following frameworks to your list of “Link Binary with Libraries” in your project’s build phases.

	• Corebluetooth.framework

### Add the framework to your project

	Link your project against the EMFramework.framework

### Add the resources bundle to your project

	To add a schema to your project, simply copy it into your application bundle. All resources provided in the EMResources.Bundle are required.  Make sure to add this bundle to your “copy bundle resources” build phase.

That’s it! You’re ready to go.

## Using Emmoco’s mobile framework

### Setup

	To begin using the mobile framework, add the following code to your application delegate’s `application:didFinishLaunchingWithOptions:`

	[[EMConnectionListManager sharedManager] startUpdating];

This tells the framework to begin scanning for available devices.

### Discovering available devices

	The class `EMConnectionListManager` is responsible for discovering devices in your proximity that are available for connection. To get a list of available devices, look at the property `devices`.

	If you want to get updates whenever devices are discovered or lost, you can use Key Value Observing (KVO).

	[[EMConnectionListManager sharedManager] addObserver:self forKeyPath:@“devices” options:0 context:NULL];

Each object in the devices array is an instance of `EMDeviceBasicDescription`. This class represents an embedded system.

### Trouble shooting

**Issue**: your embedded device is turned on, but not in the devices array

**Solution**: Make sure the schema (json file) for that device is in your project’s bundle. You can download Em-Browser from the App Store to check the schema hash on the embedded system and compare it to the schema you’re using in the app.

**Issue**: your KVO method isn’t being called when the devices array changes

**Solution**: Make sure you called startUpdating on `EMConnectionListManager`.

## Connecting to a device

	You’ve got your `EMDeviceBasicDescription` and you’re ready to connect. Where `EMConnectionListManager` is responsible for discovering available devices, `EMConnectionManager` is responsible for managing a single connection.

Here is some sample code for connecting to a device:

	EMDeviceBasicDescription *device = …
	[[EMConnectionManager sharedManager] connectDevice:device onSuccess:^{
		NSLog(@“Successfully connected!”);
	} onFail:^(NSError *error) {
		NSLog(@“%@“, [error localizedDescription]);
	}];

	The Emmoco Mobile Framework currently only supports a single connection at a time. To get the currently connected device from anywhere in your application, you can look at the `connectedDevice` property on the `EMConnectionManager`.

	There are eight possible connection states.  Refer to `EMConnection.h` to see the full list.  `connectionState` is KVO compliant.

## Reading and writing values

	Once the `connectionState` property is set to `EMConnectionStateConnected`, you are ready to read and write values.

To read a value, call:

	[[EMConnectionManager sharedManager] readResource:@“resourceName” successBlock:^(id readValue) {
		// handle successful read
	} failBlock:^(NSError *error) {
		// handle error
	}];

	The string you pass in for the resource name should match the name of the property on your mobile schema.

To write a value, call:

	[[EMConnectionManager sharedManager] writeValue:@“Hello” toResource:@“resourceName” onSuccess:^{
		// handle successful write
	} onFail:(NSError *error) {
		// handle error
	}];

	The object of type id for writing and returned when reading can be one of the following types:
	NSNumber, NSString, NSArray, NSDictionary, NSData.

	The types that you pass in and receive depend on the resource type.

NSNumber - floats, integers
NSString - enums, strings
NSArray - Arrays
NSDictionary - Structs
NSData - files

## Receiving indicators

	There are times when your application needs to be notified of events from the embedded system. These events are delivered through NSNotificationCenter.

	To get indicator notifications, subscribe to the notification like this:

	[[NSNotificationCenter defaultCenter] addObserverForName:kEMConnectionDidReceiveIndicatorNotificationName object:nil queue:[NSOperationQueue currentQueue] usingBlock:^(NSNotification *note) {
		NSDictionary *userInfo = [note userInfo];
		NSString *indicatorResourceName = [userInfo objectForKey:kEMIndicatorNameKey];
		id value = [userInfo objectForKey:kEMIndicatorResourceValueKey];
		// handle resource name and value
	}];

	The value of the indicator is of the same type that would be returned reading the resource (NSString, NSNumber, NSArray, NSDictionary, NSData).

## Reading information on broadcast

Some embedded systems choose to broadcast information with their BLE broadcast packets. You can get this information without actually connecting to the embedded system.
When you get an instance of `EMDeviceBasicDescription` from the devices property of `EMConnectionListManager`, you can look at the `advertiseObject` property. This object is a Foundation object representing the value of the broadcasted resource. If the device doesn’t have any broadcast information, this property will be nil.