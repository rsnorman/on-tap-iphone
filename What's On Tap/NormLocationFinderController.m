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
#import "NormLocationCell.h"
#import "NormLocationFinderDelegate.h"
#import "constants.h"

@interface NormLocationFinderController () <NormModalControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@end

@implementation NormLocationFinderController

@synthesize managedObjectContext;

NSArray *_locations;
UITableView *_tableView;
UIActivityIndicatorView *_spinner;
UIView *_fetchingLocationsView;

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
        
        _fetchingLocationsView = [[UIView alloc] initWithFrame:CGRectMake(0, 200, self.view.frame.size.width, 100)];
        UILabel *fetchingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 35)];
        [fetchingLabel setTextColor:[UIColor whiteColor]];
        [fetchingLabel setFont:[UIFont systemFontOfSize:14.0]];
        [fetchingLabel setTextAlignment:NSTextAlignmentCenter];
        [fetchingLabel setText: @"Searching for nearby locations"];
        [_fetchingLocationsView addSubview:fetchingLabel];
        
        _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _spinner.center = CGPointMake(self.view.frame.size.width / 2, 50);
        [_spinner startAnimating];
        [_fetchingLocationsView addSubview:_spinner];
        
        [self.view addSubview:_fetchingLocationsView];
        
        UITableViewController *tableViewController = [[UITableViewController alloc]init];
        [self addChildViewController:tableViewController];
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(25, 100, 270, self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height - 200)];
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

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    _locations = [Location fetch];
    
    if (_locations.count != 0 ) {
        [_fetchingLocationsView setHidden:YES];
        [_tableView reloadData];
    } else {
        for (Location *location in _locations) {
            NSLog(@"Name: %@", location.name);
        }
        
        [Location fetchFromServer:^(NSArray *locations){
            [self performSelectorOnMainThread:@selector(loadLocations:) withObject:locations waitUntilDone:NO];
            
        } failedWithError:nil];
    }
}

- (void) loadLocations:(NSArray *)locations
{
    _locations = locations;
    
//    for (Location *location in locations) {
//        [self saveLocation:location];
//    }
    
    [_fetchingLocationsView setHidden:YES];
    [_tableView reloadData];
    
    NSLog(@"Found Locations");
}

//- (void) saveLocation:(NormLocation *)location
//{
//    Location *_location = [NSEntityDescription insertNewObjectForEntityForName:@"Location"
//                                               inManagedObjectContext:self.managedObjectContext];
//
//    _location.name = location.name;
//    _location.lID = location.lID;
//    _location.address = location.address;
//    _location.type = location.type;
//
//    [self.managedObjectContext save:nil];  // write to database
//}

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

@end
