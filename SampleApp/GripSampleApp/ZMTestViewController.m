//
//  ZMTestViewController.m
//  GripSampleApp
//
//  Created by Dexter Weiss on 4/26/14.
//  Copyright (c) 2014 Zeta Manufacturing. All rights reserved.
//

#import "ZMTestViewController.h"
#import <GripAndShootSDK/GripAndShootSDK.h>

@interface ZMTestViewController ()

@property (nonatomic, weak) IBOutlet UIButton *connectButton;
@property (nonatomic, weak) IBOutlet UILabel *deviceNameLabel;

@property (nonatomic, weak) IBOutlet UIImageView *zoomInImage;
@property (nonatomic, weak) IBOutlet UIImageView *zoomOutImage;
@property (nonatomic, weak) IBOutlet UIImageView *captureImage;


@end

@implementation ZMTestViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    __weak typeof (self) weakSelf = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:GripAndShootSDKDidDiscoverGripNotificationName object:nil queue:[NSOperationQueue currentQueue] usingBlock:^(NSNotification *notification) {
        ZMGrip *grip = [[notification userInfo] objectForKey:GripAndShootGripUserInfoKey];
        NSLog(@"Discovered grip: %@", [grip name]);
        [weakSelf showFirstGrip];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:[NSOperationQueue currentQueue] usingBlock:^(NSNotification *note) {
        [weakSelf showFirstGrip];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_zoomInStarted) name:GripDidStartZoomingInNotificationName object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_zoomInStopped) name:GripDidStopZoomingInNotificationName object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_zoomOutStarted) name:GripDidStartZoomingOutNotificationName object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_zoomOutStopped) name:GripDidStopZoomingOutNotificationName object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_capture) name:GripDidCaptureNotificationName object:nil];
    
    [[GripAndShootSDK sharedSDK] addObserver:self forKeyPath:@"availableGrips" options:0 context:NULL];
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([GripAndShootSDK sharedSDK].connectedGrip) {
        [[self connectButton] setTitle:NSLocalizedString(@"Disconnect", nil) forState:UIControlStateNormal];
        [[self connectButton] setEnabled:YES];
    }
    else {
        [self showFirstGrip];
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == [GripAndShootSDK sharedSDK]) {
        if ([keyPath isEqualToString:@"availableGrips"]) {
            if ([[GripAndShootSDK sharedSDK] connectedGrip]) {
                // A grip is already connected -- do nothing
                return;
            }
            
            [self showFirstGrip];
        }
    }
}

-(void)showFirstGrip {
    if ([[GripAndShootSDK sharedSDK] connectedGrip]) {
        [[self connectButton] setTitle:NSLocalizedString(@"Disconnect", nil) forState:UIControlStateNormal];
        [[self connectButton] setEnabled:YES];
    }
    else if ([[[GripAndShootSDK sharedSDK] availableGrips] count]) {
        ZMGrip *firstGrip = [[[GripAndShootSDK sharedSDK] availableGrips] firstObject];
        [[self deviceNameLabel] setText:[firstGrip name]];
        [[self connectButton] setEnabled:YES];
        [[self connectButton] setTitle:NSLocalizedString(@"Connect", nil) forState:UIControlStateNormal];
    }
    else {
        [[self deviceNameLabel] setText:NSLocalizedString(@"Scanning...", nil)];
        [[self connectButton] setEnabled:NO];
    }
}

-(IBAction)connectButtonPressed:(id)sender {
    __weak typeof (self) weakSelf = self;
    if ([[GripAndShootSDK sharedSDK] connectedGrip]) {
        [[GripAndShootSDK sharedSDK] disconnectGripWithSuccessBlock:^{
            [weakSelf showFirstGrip];
        } failBlock:^(NSError *error) {
            [weakSelf showFirstGrip];
        }];
    }
    else {
        [[self connectButton] setEnabled:NO];
        ZMGrip *grip = [[[GripAndShootSDK sharedSDK] availableGrips] firstObject];
        [[GripAndShootSDK sharedSDK] connectToGrip:grip withSuccessBlock:^{
            [[self connectButton] setTitle:NSLocalizedString(@"Disconnect", nil) forState:UIControlStateNormal];
            [[self connectButton] setEnabled:YES];
        } failBlock:^(NSError *error) {
            [[self connectButton] setEnabled:YES];
        }];
    }
}

#pragma mark - Grip indicators

-(void)_zoomInStarted {
    [[self zoomInImage] setHighlighted:YES];
}

-(void)_zoomInStopped {
    [[self zoomInImage] setHighlighted:NO];
}

-(void)_zoomOutStarted {
    [[self zoomOutImage] setHighlighted:YES];
}

-(void)_zoomOutStopped {
    [[self zoomOutImage] setHighlighted:NO];
}

-(void)_capture {
    [[self captureImage] setHighlighted:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[self captureImage] setHighlighted:NO];
    });
}

@end
