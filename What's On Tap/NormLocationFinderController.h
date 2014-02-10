//
//  NormLocationFinderController.h
//  On Tap
//
//  Created by Ryan Norman on 1/14/14.
//  Copyright (c) 2014 Ryan Norman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NormLocationFinderDelegate.h"
#import "Location.h"
#import "NormIndicatorView.h"
#import "NormConnectionManager.h"
#import "NormLocationTableViewController.h"
#import <CoreLocation/CoreLocation.h>


@interface NormLocationFinderController : UIViewController

@property id <NormLocationFinderDelegate> delegate;

@property BOOL isUpdatingLocations;
@property Location *selectedLocation;

@property NormIndicatorView *locationSearchIndicator;
@property NormLocationTableViewController *locationsTableViewController;
@property UITableView *locationsTableView;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic) NormConnectionManager *connectionManager;
@property (nonatomic, strong) CLLocationManager *myLocationManager;

@end
