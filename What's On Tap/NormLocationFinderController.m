//
//  NormLocationFinderController.m
//  On Tap
//
//  Created by Ryan Norman on 1/14/14.
//  Copyright (c) 2014 Ryan Norman. All rights reserved.
//
#import "constants.h"

#import "NormLocationFinderController.h"
#import "User.h"

#import "NormLocationFinderDelegate.h"
#import "NormConnectionManagerDelegate.h"
#import "NormModalControllerDelegate.h"
#import "NormLocationTableViewControllerDelegate.h"
#import "NormBeerTableViewController.h"
#import "NormLocationMapViewController.h"
#import "TestFlight.h"

#import <UIKit/UIKit.h>


@interface NormLocationFinderController () <NormModalControllerDelegate, CLLocationManagerDelegate, NormConnectionManagerDelegate, NormLocationTableViewControllerDelegate, NormLocationMapViewControllerDelegate>

@property (retain, nonatomic, readonly) UILabel *titleLabel;
@end

@implementation NormLocationFinderController

@synthesize managedObjectContext;
BOOL locationsLoaded;
float maxDistanceRadius;


- (id)init
{
    self = [super init];
    
    if (self) {
        self.isUpdatingLocations = NO;

        self.locationSearchIndicator = [[NormIndicatorView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width * 0.7, 150)];
        [self.locationSearchIndicator setCenter:CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2)];
        [self.view addSubview:self.locationSearchIndicator];
        [self.locationSearchIndicator setMessage:@"Finding nearby locations"];
        [self.locationSearchIndicator startAnimating];
        
        self.locationsTableViewController = [[NormLocationTableViewController alloc]init];
        [self.locationsTableViewController setDelegate:self];
        [self addChildViewController:self.locationsTableViewController];
        
        self.locationsTableView = [[UITableView alloc] initWithFrame:self.view.frame];
        self.locationsTableView.dataSource = self.locationsTableViewController;
        self.locationsTableView.delegate = self.locationsTableViewController;
        self.locationsTableView.backgroundColor = [UIColor clearColor];
        self.locationsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.locationsTableView setContentInset:UIEdgeInsetsMake(75,0,75,0)];
        
        self.locationsTableViewController.tableView = self.locationsTableView;
        [self.view addSubview:self.locationsTableView];
        
        id appDelegate = (id)[[UIApplication sharedApplication] delegate];
        self.managedObjectContext = [appDelegate managedObjectContext];
        
        
        self.myLocationManager = [[CLLocationManager alloc] init];
        self.myLocationManager.delegate = self;
        
        
        self.connectionManager = [[NormConnectionManager alloc] init];
        [self.connectionManager setDelegate:self];
        [self.connectionManager performSelectorInBackground:@selector(checkForConnection) withObject:nil];
        
        
        CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, 65);
        UIImageView *bgHeaderImageView = [[UIImageView alloc] initWithFrame:frame];
        UIImageView *bgFooterImageView = [[UIImageView alloc] initWithFrame:CGRectOffset(frame, 0, self.view.frame.size.height - 65)];
        
        [self.view addSubview:bgHeaderImageView];
        [self.view addSubview:bgFooterImageView];
        
        UIImage *gradientImage = [self drawGradientForFrame:frame];
        [bgHeaderImageView setImage:gradientImage];
        UIImage *flippedImage = [[UIImage alloc] initWithCGImage:gradientImage.CGImage scale:1.0 orientation:UIImageOrientationDownMirrored];
        [bgFooterImageView setImage:flippedImage];
        
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, -35, self.view.frame.size.width, 35)];
        [self.titleLabel setFont:[UIFont fontWithName:_PRIMARY_FONT size:26.0f]];
        [self.titleLabel setText:@"Select Location"];
        [self.titleLabel setTextColor:[UIColor whiteColor]];
        [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
        
        [self.view addSubview:self.titleLabel];
        
        
        self.viewAllLocationsButton = [[UIButton alloc] initWithFrame:CGRectMake(10, self.view.frame.size.height, 60, 60)];
        [_viewAllLocationsButton setImage:[UIImage imageNamed:@"map-marker"] forState:UIControlStateNormal];
        [_viewAllLocationsButton setBackgroundColor:_MAIN_COLOR];
        [_viewAllLocationsButton.layer setCornerRadius:30];
        [_viewAllLocationsButton addTarget:self action:@selector(showAllLocationsOnMap) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:_viewAllLocationsButton];
        
        locationsLoaded = NO;
        maxDistanceRadius = 30.0;
    }
    
    return self;
}


- (void)didConnectToNetwork
{
    [self.locationSearchIndicator setMessage:@"Finding nearby locations"];
    [self.locationSearchIndicator startAnimating];
//    [self.locationsTableView setHidden:NO];
    
    if ([CLLocationManager locationServicesEnabled]) {
        [self.myLocationManager startUpdatingLocation];
    } else {
        [self.locationSearchIndicator setErrorMessage:@"Please turn on location services in Settings"];
//        [self.locationsTableView setHidden:YES];
    }
}

- (void)didDisconnectFromNetwork
{
    if (!locationsLoaded) {
        [self.locationSearchIndicator setErrorMessage:@"Please connect to the Internet"];
//        [self.locationsTableView setHidden:YES];
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusDenied) {
        [self.locationSearchIndicator setErrorMessage:@"Please turn on location services in Settings"];
        [self.locationsTableView setHidden:YES];
        
        [TestFlight passCheckpoint:@"Would Not Turn On Location Services"];
    }
}

- (UIImage *) drawGradientForFrame:(CGRect) rect
{
    // Create a gradient from white to red
    CGFloat colors [] = {
        0.0, 0.0, 0.0, 1.0,
        0.0, 0.0, 0.0, 0.0
    };
    
    UIGraphicsBeginImageContext(rect.size);
    
    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, colors, NULL, 2);
    CGColorSpaceRelease(baseSpace), baseSpace = NULL;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(context);
    
    CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
    
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGGradientRelease(gradient), gradient = NULL;
    
    CGContextRestoreGState(context);
    
    CGImageRef imgRef = CGBitmapContextCreateImage(context);
    UIImage* img = [UIImage imageWithCGImage:imgRef];
    CGImageRelease(imgRef);
    CGContextRelease(context);
    
    return img;
}

- (void) showError
{
    [self.locationSearchIndicator setErrorMessage:@"There was a problem finding nearby locations.\nAre you in a dry county?"];
    [self.locationsTableView setHidden:YES];
    
    [TestFlight passCheckpoint:@"Error Finding Locations"];
}

- (void) loadLocations:(NSArray *)locations
{
    if (locations.count > 0) {
        [self.locationSearchIndicator stopAnimating];
        [self.locationsTableViewController setLocations:locations];
        self.locations = locations;
        locationsLoaded = YES;
        
        [UIView animateWithDuration:0.4
                              delay:0.0
                            options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.titleLabel.frame = CGRectOffset(self.titleLabel.frame, 0, 50);
                         }
                         completion:^(BOOL finished) {
                             
                         }];
    } else {
        [self.locationSearchIndicator stopAnimating];
        [self.locationSearchIndicator setMessage:@"Couldn't find any nearby locations.\nAre you in a dry county?"];
        [self.locationsTableView setHidden:YES];
        
        [TestFlight passCheckpoint:@"Could Not Find Locations"];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)modalShouldBeDismissed
{
    
    // Slide out table view before dismissing modal controller
    self.locationsTableView.layer.opacity = 1.0;
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut
                     animations:^
     {
         self.locationsTableView.frame = CGRectOffset(self.locationsTableView.frame, self.view.frame.size.width * -1, 0);
         self.locationsTableView.layer.opacity = 0.0;
     }
                     completion:^(BOOL finished) {
                         [[self presentingViewController] dismissViewControllerAnimated:YES completion:^() {
                             if (self.selectedLocation != nil) {
                                 [self.delegate setLocation:self.selectedLocation];
                             }
                         }];
                     }];
    
}

- (void) didSelectLocation:(Location *)selectedLocation
{
    self.selectedLocation = selectedLocation;
    [self modalShouldBeDismissed];
}

- (void) didSelectLocationMap:(Location *)location
{
    [TestFlight passCheckpoint:@"Viewed Location on Map"];
    NormLocationMapViewController *locationMapController = [[NormLocationMapViewController alloc] init];
    [locationMapController setLocations:@[location]];
    [locationMapController setUserLocation:self.currentLocation];
    [locationMapController setDelegate:self];
    [self presentViewController:locationMapController animated:YES completion:nil];
}

- (void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    [self.myLocationManager stopUpdatingLocation]; 
    
    if (!self.isUpdatingLocations) {
        self.isUpdatingLocations = YES;
        self.currentLocation = newLocation;
        [Location fetchFromServerForLat: newLocation.coordinate.latitude andLong: newLocation.coordinate.longitude success:^(NSArray *locations){
            
            NSPredicate *distancePredicate = [NSPredicate predicateWithFormat:@"SELF.distanceAway.floatValue <= %f", maxDistanceRadius];
            
            locations = [locations filteredArrayUsingPredicate:distancePredicate];
            
            [self performSelectorOnMainThread:@selector(loadLocations:) withObject:locations waitUntilDone:NO];
            
            [self performSelectorOnMainThread:@selector(slideInLocationsMapButton) withObject:locations waitUntilDone:NO];
            
        } failedWithError:^(NSError *error){
            [self performSelectorOnMainThread:@selector(showError) withObject:error waitUntilDone:NO];
        }];
    }
}

- (void) showAllLocationsOnMap
{
    [TestFlight passCheckpoint:@"Viewed All Locations on Map"];
    NormLocationMapViewController *locationMapController = [[NormLocationMapViewController alloc] init];
    [locationMapController setLocations:self.locations];
    [locationMapController setUserLocation:self.currentLocation];
    [locationMapController setDelegate:self];
    [self presentViewController:locationMapController animated:YES completion:nil];
}

- (void) slideInLocationsMapButton
{
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^
     {
         self.viewAllLocationsButton.frame = CGRectOffset(self.viewAllLocationsButton.frame, 0, -70);
     }
                     completion:nil];
}

- (void) didSelectViewLocationMenu:(Location *)location
{
    
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:^() {
        [self.delegate setLocation:location];
    }];
}


@end
