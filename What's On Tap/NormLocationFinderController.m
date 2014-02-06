//
//  NormLocationFinderController.m
//  On Tap
//
//  Created by Ryan Norman on 1/14/14.
//  Copyright (c) 2014 Ryan Norman. All rights reserved.
//

#import "NormLocationFinderController.h"
#import "NormModalControllerDelegate.h"
#import "Location.h"
#import "User.h"
#import "NormLocationCell.h"
#import "NormIndicatorView.h"
#import "NormLocationFinderDelegate.h"
#import "constants.h"
#import <CoreLocation/CoreLocation.h>

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
        _locations = [[NSMutableArray alloc] init];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, self.view.frame.size.width, 35)];
        [titleLabel setFont:[UIFont fontWithName:_SECONDARY_FONT size:22.0f]];
        [titleLabel setText:@"Select Location"];
        [titleLabel setTextColor:[UIColor whiteColor]];
        [titleLabel setTextAlignment:NSTextAlignmentCenter];
        
        [self.view addSubview:titleLabel];

        _spinner = [[NormIndicatorView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 125)];
        _spinner.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
        [_spinner startAnimating];
        [_spinner setMessage:@"Fetching nearby locations"];
        [_spinner.spinner setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
        [_spinner.spinner setBackgroundColor:[UIColor clearColor]];
        [_spinner.messageLabel setTextColor:[UIColor whiteColor]];
        [self.view addSubview:_spinner];
        
        UITableViewController *tableViewController = [[UITableViewController alloc]init];
        [self addChildViewController:tableViewController];
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(25, 100, 270, self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height - 100)];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        
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
        
        NSLog(@"Start updating location");
        
        [self.myLocationManager startUpdatingLocation];
    }

}

//- (void)viewDidAppear:(BOOL)animated
//{
//    [super viewDidAppear:animated];
//    
//    _locations = [Location fetch];
//    
//    if (_locations.count != 0 && false) {
//        [_spinner setHidden:YES];
//        [_tableView reloadData];
//    } else {
//        for (Location *location in _locations) {
//            NSLog(@"Name: %@", location.name);
//        }
//        
//        
//    }
//}

- (void) showError
{
    [_spinner stopAnimating];
    [_spinner setMessage:@"There was an error fetching locations"];
    [_tableView setHidden:YES];
}

- (void) loadLocations:(NSArray *)locations
{
    _locations = locations;
    
    [_spinner setHidden:YES];
    [_tableView reloadData];
    
    NSLog(@"Found Locations");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)modalShouldBeDismissed
{
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
    
    NormLocation *location = [_locations objectAtIndex:indexPath.row];
    [self.delegate setLocation:location];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 75;
}

- (void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"Latitude = %f", newLocation.coordinate.latitude);
    NSLog(@"Latitude = %f", newLocation.coordinate.longitude);
    
    [self.myLocationManager stopUpdatingLocation];
    
    [Location fetchFromServerForLat: newLocation.coordinate.latitude andLong: newLocation.coordinate.longitude success:^(NSArray *locations){
        
        NSLog(@"locations found");
        [self performSelectorOnMainThread:@selector(loadLocations:) withObject:locations waitUntilDone:NO];
        
    } failedWithError:^(NSError *error){
        NSLog(@"There was an error: %@", error);
        [self performSelectorOnMainThread:@selector(showError) withObject:error waitUntilDone:NO];
    }];
}

@end
