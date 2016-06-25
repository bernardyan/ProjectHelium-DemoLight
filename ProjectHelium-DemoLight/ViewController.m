//
//  ViewController.m
//  ProjectHelium-DemoLight
//
//  Created by Bernard Yan on 6/24/16.
//  Copyright © 2016 IntBridge. All rights reserved.
//

#import "ViewController.h"
@import CoreBluetooth;
@import CoreLocation;

@interface ViewController ()<CBPeripheralManagerDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) CBPeripheralManager *peripheralManager;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLBeaconRegion *broadcastRegion;
@property (strong, nonatomic) CLBeaconRegion *rangingRegion;
@property (strong, nonatomic) NSMutableDictionary *peripheralData;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSLog(@"View did load");
    
    self.view.backgroundColor = [UIColor darkGrayColor];
    
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self
                                                                     queue:nil
                                                                   options:nil];
    
    NSUUID *broadcastUUID = [[NSUUID alloc] initWithUUIDString:@"778DCA1F-1817-4D78-BD4F-F7549155D914"];
    NSUUID *rangingUUID = [[NSUUID alloc] initWithUUIDString:@"778DCA1F-1817-4D78-BD4F-F7549155D915"];
    
    self.broadcastRegion = [[CLBeaconRegion alloc] initWithProximityUUID:broadcastUUID major:0 minor:0 identifier:@"Helium-broadcast"];
    self.rangingRegion = [[CLBeaconRegion alloc] initWithProximityUUID:rangingUUID identifier:@"Helium-receive"];
    
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    if([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.locationManager requestAlwaysAuthorization];
    }
    
    [self.locationManager startRangingBeaconsInRegion:self.rangingRegion];
    
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    
    if (peripheral.state == CBPeripheralManagerStatePoweredOn) {
        
        self.peripheralData = [self.broadcastRegion peripheralDataWithMeasuredPower:nil];
        [self.peripheralManager startAdvertising:self.peripheralData];
        
    }
    
}

-(void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray<CLBeacon *> *)beacons inRegion:(CLBeaconRegion *)region {
    
    CLBeacon *beacon = [beacons firstObject];

    if ([beacon.major isEqual:[NSNumber numberWithInt:11]]) {
        
        if (beacon.rssi == 0) {//when beacon broadcast stops, the delegate still get called for a few seconds, but we can know it from rssi value
            self.view.backgroundColor = [UIColor darkGrayColor];
        }else{
            self.view.backgroundColor = [UIColor whiteColor];
        }
        
    }else{
        self.view.backgroundColor = [UIColor darkGrayColor];
    }
    
    //NSLog([beacon.major description]);
    NSLog([beacon description]);
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
