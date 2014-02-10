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

#import <UIKit/UIKit.h>


@interface NormLocationFinderController () <NormModalControllerDelegate, CLLocationManagerDelegate, NormConnectionManagerDelegate, NormLocationTableViewControllerDelegate>
@end

@implementation NormLocationFinderController

@synthesize managedObjectContext;

- (id)init
{
    self = [super init];
    
    if (self) {
        self.isUpdatingLocations = NO;

        self.locationSearchIndicator = [[NormIndicatorView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 150)];
        self.locationSearchIndicator.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
        [self.locationSearchIndicator startAnimating];
        [self.locationSearchIndicator setMessage:@"Grabbing nearby locations"];
        [self.locationSearchIndicator.spinner setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
        [self.locationSearchIndicator.spinner setBackgroundColor:[UIColor clearColor]];
        [self.locationSearchIndicator.messageLabel setTextColor:[UIColor whiteColor]];
        [self.view addSubview:self.locationSearchIndicator];
        
        self.locationsTableViewController = [[NormLocationTableViewController alloc]init];
        [self.locationsTableViewController setDelegate:self];
        [self addChildViewController:self.locationsTableViewController];
        
        self.locationsTableView = [[UITableView alloc] initWithFrame:self.view.frame];
        self.locationsTableView.dataSource = self.locationsTableViewController;
        self.locationsTableView.delegate = self.locationsTableViewController;
        self.locationsTableView.backgroundColor = [UIColor clearColor];
        self.locationsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.locationsTableView setContentInset:UIEdgeInsetsMake(50,0,0,0)];
        
        self.locationsTableViewController.tableView = self.locationsTableView;
        [self.view addSubview:self.locationsTableView];
        
        id appDelegate = (id)[[UIApplication sharedApplication] delegate];
        self.managedObjectContext = [appDelegate managedObjectContext];
        
        
        self.myLocationManager = [[CLLocationManager alloc] init];
        self.myLocationManager.delegate = self;
        
        
        self.connectionManager = [[NormConnectionManager alloc] init];
        [self.connectionManager setDelegate:self];
        
        
        if ([CLLocationManager locationServicesEnabled]) {
            
            if ([self.connectionManager connectedToNetwork]) {
                [self.myLocationManager startUpdatingLocation];
            } else {
                [self.locationSearchIndicator stopAnimating];
                [self.locationSearchIndicator setMessage:@"Please connect to the Internet"];
                [self.locationsTableView setHidden:YES];
            }
            
        } else {
            [self.locationSearchIndicator stopAnimating];
            [self.locationSearchIndicator setMessage:@"Please turn on location services in Settings"];
            [self.locationsTableView setHidden:YES];
        }
    }
    
    return self;
}

- (void)didConnectToNetwork
{
    [self.locationSearchIndicator startAnimating];
    [self.locationSearchIndicator setMessage:@"Grabbing nearby locations"];
    [self.myLocationManager startUpdatingLocation];
    [self.locationsTableView setHidden:NO];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusDenied) {
        [self.locationSearchIndicator stopAnimating];
        [self.locationSearchIndicator setMessage:@"Please turn on location services in Settings"];
        [self.locationsTableView setHidden:YES];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    
    CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, 65);
    UIImageView *bgHeaderImageView = [[UIImageView alloc] initWithFrame:frame];
    UIImageView *bgFooterImageView = [[UIImageView alloc] initWithFrame:CGRectOffset(frame, 0, self.view.frame.size.height - 65)];
    
    [self.view addSubview:bgHeaderImageView];
    [self.view addSubview:bgFooterImageView];
    
    UIImage *gradientImage = [self drawGradientForFrame:frame];
    [bgHeaderImageView setImage:gradientImage];
    UIImage *flippedImage = [[UIImage alloc] initWithCGImage:gradientImage.CGImage scale:1.0 orientation:UIImageOrientationDownMirrored];
    [bgFooterImageView setImage:flippedImage];
    
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, self.view.frame.size.width, 35)];
    [titleLabel setFont:[UIFont fontWithName:_SECONDARY_FONT size:22.0f]];
    [titleLabel setText:@"Select Location"];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    
    [self.view addSubview:titleLabel];
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
    [self.locationSearchIndicator stopAnimating];
    [self.locationSearchIndicator setMessage:@"There was a problem finding nearby locations.\nAre you in a dry county?"];
    [self.locationsTableView setHidden:YES];
}

- (void) loadLocations:(NSArray *)locations
{
    if (locations.count > 0) {
        [self.locationSearchIndicator setHidden:YES];
        [self.locationsTableViewController setLocations:locations];
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

- (void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    [self.myLocationManager stopUpdatingLocation]; 
    
    if (!self.isUpdatingLocations) {
        self.isUpdatingLocations = YES;
        [Location fetchFromServerForLat: newLocation.coordinate.latitude andLong: newLocation.coordinate.longitude success:^(NSArray *locations){
            
            [self performSelectorOnMainThread:@selector(loadLocations:) withObject:locations waitUntilDone:NO];
            
        } failedWithError:^(NSError *error){
            [self performSelectorOnMainThread:@selector(showError) withObject:error waitUntilDone:NO];
        }];
    }
}

@end
