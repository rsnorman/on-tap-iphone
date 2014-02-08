//
//  NormLocationFinderController.m
//  On Tap
//
//  Created by Ryan Norman on 1/14/14.
//  Copyright (c) 2014 Ryan Norman. All rights reserved.
//

#import "NormLocationFinderController.h"
#import "NormModalControllerDelegate.h"
#import "User.h"
#import "NormLocationCell.h"
#import "NormIndicatorView.h"
#import "NormLocationFinderDelegate.h"
#import "NormViewSnapshot.h"
#import "constants.h"
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

@interface NormLocationFinderController () <NormModalControllerDelegate, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *myLocationManager;


@end

@implementation NormLocationFinderController

@synthesize managedObjectContext;

NSArray *_locations;
UITableView *_tableView;
NormIndicatorView *_spinner;

- (id)init
{
    self = [super init];
    
    if (self) {
        self.displayCount = 0;
        self.isUpdatingLocations = NO;
        
        _locations = [[NSMutableArray alloc] init];

        _spinner = [[NormIndicatorView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 150)];
        _spinner.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
        [_spinner startAnimating];
        [_spinner setMessage:@"Grabbing nearby locations"];
        [_spinner.spinner setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
        [_spinner.spinner setBackgroundColor:[UIColor clearColor]];
        [_spinner.messageLabel setTextColor:[UIColor whiteColor]];
        [self.view addSubview:_spinner];
        
        UITableViewController *tableViewController = [[UITableViewController alloc]init];
        [self addChildViewController:tableViewController];
        
        _tableView = [[UITableView alloc] initWithFrame:self.view.frame];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView setContentInset:UIEdgeInsetsMake(50,0,0,0)];
        
        tableViewController.tableView = _tableView;
        [self.view addSubview:_tableView];
    }
    
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    id appDelegate = (id)[[UIApplication sharedApplication] delegate];
    self.managedObjectContext = [appDelegate managedObjectContext];
    
    if ([CLLocationManager locationServicesEnabled]) {
        self.myLocationManager = [[CLLocationManager alloc] init];
        self.myLocationManager.delegate = self;
        [self.myLocationManager startUpdatingLocation];
    } else {
        [_spinner stopAnimating];
        [_spinner setMessage:@"Please turn on location services in Settings"];
        [_tableView setHidden:YES];
    }

}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusDenied) {
        [_spinner stopAnimating];
        [_spinner setMessage:@"Please turn on location services in Settings"];
        [_tableView setHidden:YES];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    
    CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, 65);
    UIImageView *bgHeaderImageView = [[UIImageView alloc] initWithFrame:frame];
    UIImageView *bgFooterImageView = [[UIImageView alloc] initWithFrame:CGRectOffset(frame, 0, self.view.frame.size.height - 65)];
    
    [self.view addSubview:bgHeaderImageView];
    [self.view addSubview:bgFooterImageView];
    
    
    CGRect rect = frame;
    
    // Create a gradient from white to red
    CGFloat colors [] = {
        0.0, 0.0, 0.0, 1.0,
        0.0, 0.0, 0.0, 0.0
    };
    
    UIGraphicsBeginImageContext(frame.size);
    
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
    
    
    [bgHeaderImageView setImage:img];
    UIImage *flippedImage = [[UIImage alloc] initWithCGImage:img.CGImage scale:1.0 orientation:UIImageOrientationDownMirrored];
    [bgFooterImageView setImage:flippedImage];
    
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, self.view.frame.size.width, 35)];
    [titleLabel setFont:[UIFont fontWithName:_SECONDARY_FONT size:22.0f]];
    [titleLabel setText:@"Select Location"];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    
    [self.view addSubview:titleLabel];
}


- (void) showError
{
    [_spinner stopAnimating];
    [_spinner setMessage:@"There was a problem finding nearby locations.\nAre you in a dry county?"];
    [_tableView setHidden:YES];
}

- (void) loadLocations:(NSArray *)locations
{
    _locations = locations;
    
    if (_locations.count > 0) {
        [_spinner setHidden:YES];
        [self setIsAnimating:YES];
        [self setDelayCellDisplay:YES];
        [_tableView reloadData];
        
        [self performSelector:@selector(setDelayCellDisplay:) withObject:NO afterDelay:1.0];
    } else {
        [_spinner stopAnimating];
        [_spinner setMessage:@"Couldn't find any nearby locations.\nAre you in a dry county?"];
        [_tableView setHidden:YES];
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
    _tableView.layer.opacity = 1.0;
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut
                     animations:^
     {
         _tableView.frame = CGRectOffset(_tableView.frame, self.view.frame.size.width * -1, 0);
         _tableView.layer.opacity = 0.0;
     }
                     completion:^(BOOL finished) {
                         [[self presentingViewController] dismissViewControllerAnimated:YES completion:^() {
                             NSLog(@"Set Location: %@", self.selectedLocation.lID);
                             if (self.selectedLocation != nil) {
                                 [self.delegate setLocation:self.selectedLocation];
                             }
                         }];
                     }];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_locations count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *normTableCellIdentifier = @"NormLocationCell";

    NormLocationCell *cell = (NormLocationCell *)[tableView dequeueReusableCellWithIdentifier:normTableCellIdentifier];
    if (cell == nil)
    {
        cell = [[NormLocationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:normTableCellIdentifier];
    }
    
    [cell setLocation:[_locations objectAtIndex:indexPath.row]];
    
    [cell displayLabel];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(NormLocationCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // Only slide in cells one time to keep cool animation from becoming annoying
    if (self.displayCount > indexPath.row) {
        return;
    }
 
    self.displayCount = self.displayCount + 1;
    
    NSTimeInterval delay;
    if (self.delayCellDisplay) {
        delay = 0.05 * self.displayCount;
    } else {
        delay = 0.0;
    }
    
    cell.frame = CGRectMake(320, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height);
    [UIView animateWithDuration:0.5
                          delay:delay
         usingSpringWithDamping:0.6
          initialSpringVelocity:4.0
                        options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut
                     animations:^
     {
         cell.frame = CGRectMake(0, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.width);
     }
                     completion:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedLocation = [_locations objectAtIndex:indexPath.row];
    
    [self modalShouldBeDismissed];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
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
