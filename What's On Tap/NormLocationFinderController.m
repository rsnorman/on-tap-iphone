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

#import <UIKit/UIKit.h>


@interface NormLocationFinderController () <NormModalControllerDelegate, CLLocationManagerDelegate, NormConnectionManagerDelegate, NormLocationTableViewControllerDelegate, NormLocationMapViewControllerDelegate>

@property (retain, nonatomic, readonly) UILabel *titleLabel;
@property (retain, nonatomic) UILabel *addressLabel;
@property (retain, nonatomic) UIView *addressView;
@property (retain, nonatomic) UIImageView *addressEditIcon;
@property (retain, nonatomic) UITextField *addressTextField;
@property (retain, nonatomic) CLGeocoder *geoCoder;

@property BOOL isReversingGeocoding;

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
        
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, -55, self.view.frame.size.width, 35)];
        [self.titleLabel setFont:[UIFont fontWithName:_PRIMARY_FONT size:26.0f]];
        [self.titleLabel setText:@"Select Location"];
        [self.titleLabel setTextColor:[UIColor whiteColor]];
        [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
        
        [self.view addSubview:self.titleLabel];
        
        _addressView = [[UIView alloc] initWithFrame:CGRectMake(0, -35, self.view.frame.size.width, 35)];
        [self.view addSubview:_addressView];
        
        _addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 25)];
        [self.addressLabel setFont:[UIFont fontWithName:_TERTIARY_FONT size:16.0f]];
        [self.addressLabel setText:@""];
        [self.addressLabel setTextColor:[UIColor whiteColor]];
        [self.addressLabel setTextAlignment:NSTextAlignmentCenter];
        
//        [self.addressView addSubview:self.addressLabel];
        
        _addressEditIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"location-arrow"]];
        [self.addressView addSubview:_addressEditIcon];
        _addressEditIcon.frame = CGRectMake(270, 1, 10, 10);
        
        _addressTextField = [[UITextField alloc] initWithFrame:CGRectMake(75, 0, self.view.frame.size.width, 25)];
        [_addressTextField setPlaceholder:@"Enter Location"];
        [_addressTextField setTintColor:[UIColor whiteColor]];
        [_addressTextField setTextColor:[UIColor whiteColor]];
        _addressTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Enter Location" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
        _addressTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        [self.addressLabel setTextAlignment:NSTextAlignmentCenter];
        
        UITapGestureRecognizer *changeLocationTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editLocation)];
        changeLocationTap.numberOfTapsRequired = 1;
        
        [_addressEditIcon setUserInteractionEnabled:YES];
        [_addressLabel setUserInteractionEnabled:YES];
        [_addressTextField addGestureRecognizer:changeLocationTap];
        [_addressEditIcon addGestureRecognizer:changeLocationTap];
        
        [self.addressView addSubview:_addressTextField];
        
        
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
    [self performSelectorOnMainThread:@selector(startLocationSearch) withObject:nil waitUntilDone:NO];
}

- (void)startLocationSearch
{
    [self.locationSearchIndicator setMessage:@"Finding nearby locations"];
    [self.locationSearchIndicator startAnimating];
    
    if ([CLLocationManager locationServicesEnabled]) {
        [self.myLocationManager startUpdatingLocation];
    } else {
        [self.locationSearchIndicator setErrorMessage:@"Please turn on location services in Settings"];
    }
}

- (void)didDisconnectFromNetwork
{
    if (!locationsLoaded) {
        [self.locationSearchIndicator performSelectorOnMainThread:@selector(setErrorMessage:) withObject:@"Please connect to the Internet" waitUntilDone:NO];
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusDenied) {
        [self.locationSearchIndicator setErrorMessage:@"Please turn on location services in Settings"];
        [self.locationsTableView setHidden:YES];
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
                             self.titleLabel.frame = CGRectOffset(self.titleLabel.frame, 0, 70);
                         }
                         completion:^(BOOL finished) {
                             
                         }];
        
        if (!self.isReversingGeocoding) {
            [self showAddressView];
        }
        
    } else {
        [self.locationSearchIndicator stopAnimating];
        [self.locationSearchIndicator setMessage:@"Couldn't find any nearby locations.\nAre you in a dry county?"];
        [self.locationsTableView setHidden:YES];
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
        
        [self reverseGeocode:self.currentLocation];
        
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

- (void)reverseGeocode:(CLLocation *)location {
    
    self.isReversingGeocoding = YES;
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        NSLog(@"Finding address");
        if (error) {
            NSLog(@"Error %@", error.description);
        } else {
            CLPlacemark *placemark = [placemarks lastObject];

            [self performSelectorOnMainThread:@selector(setAddress:) withObject:placemark.addressDictionary waitUntilDone:NO];
            
        }
    }];
}

- (void)setAddress:(NSDictionary *)addressDictionary
{
    NSString *address = [NSString stringWithFormat:@"%@, %@", [addressDictionary objectForKey:@"City"], [addressDictionary objectForKey:@"State"]];
    [self.addressLabel setText:address];
    [self.addressLabel sizeToFit];
    _addressLabel.frame = CGRectMake((self.addressView.frame.size.width / 2) - (self.addressLabel.frame.size.width / 2), self.addressLabel.frame.origin.y, self.addressLabel.frame.size.width, self.addressLabel.frame.size.height);
    _addressEditIcon.frame = CGRectMake(_addressLabel.frame.origin.x + _addressLabel.frame.size.width + 5, _addressEditIcon.frame.origin.y, _addressEditIcon.frame.size.width, _addressEditIcon.frame.size.height);
    
    _addressTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:address attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    
    self.isReversingGeocoding = NO;
    
    if (!self.isUpdatingLocations) {
        [self showAddressView];
    }
}

- (void)showAddressView
{
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.addressView.frame = CGRectOffset(self.addressView.frame, 0, 85);
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

- (void) showAllLocationsOnMap
{
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

- (void) editLocation
{
    [UIView animateWithDuration:0.7
                     animations:^{
                         _addressTextField.layer.opacity = 1.0;
                         _addressEditIcon.layer.opacity = 0.0;
                         _addressLabel.layer.opacity = 0.0;
                     }
                     completion:^(BOOL finished) {
    
                     }];
}

@end
