//
//  NormLocationFinderController.m
//  On Tap
//
//  Created by Ryan Norman on 1/14/14.
//  Copyright (c) 2014 Ryan Norman. All rights reserved.
//

#import "NormLocationFinderController.h"
#import "NormModalControllerDelegate.h"
#import "NormLocation.h"
#import "NormLocationCell.h"
#import "NormLocationFinderDelegate.h"
#import "constants.h"

@interface NormLocationFinderController () <NormModalControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@end

@implementation NormLocationFinderController

NSMutableArray *_locations;
UITableView *_tableView;
UIActivityIndicatorView *_spinner;

- (id)init
{
    self = [super init];
    
    if (self) {
        _locations = [[NSMutableArray alloc] init];
//
//        NSArray *locationsJSON = @[@{@"name": @"Whichcraft Taproom", @"locationId": @"11580", @"type": @"Bar", @"address": @"124 Ashman St. Midland, MI 48642"}, @{@"name": @"Big E's Sports Grill", @"locationId": @"12576", @"type": @"Restaurant", @"address": @"810 Cinema Dr. Midland, MI 48642"}, @{@"name": @"Fenton Fire House", @"locationId": @"13337", @"type": @"Restaurant", @"address": @"201. S. Leroy St. Fenton, MI 48430"}];
//        
//        for(NSDictionary *locationDic in locationsJSON) {
//            NormLocation *location = [[NormLocation alloc] init];
//            for (NSString *key in locationDic) {
//                if ([location respondsToSelector:NSSelectorFromString(key)]) {
//                    [location setValue:[locationDic valueForKey:key] forKey:key];
//                }
//            }
//            
//            [_locations addObject:location];
//        }
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, self.view.frame.size.width, 35)];
        [titleLabel setFont:[UIFont fontWithName:_SECONDARY_FONT size:22.0f]];
        [titleLabel setText:@"Select Location"];
        [titleLabel setTextColor:[UIColor whiteColor]];
        [titleLabel setTextAlignment:NSTextAlignmentCenter];
        
        [self.view addSubview:titleLabel];
        
        UIView *fetchingLocationsView = [[UIView alloc] initWithFrame:CGRectMake(0, 200, self.view.frame.size.width, 100)];
        UILabel *fetchingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 35)];
        [fetchingLabel setTextColor:[UIColor whiteColor]];
        [fetchingLabel setFont:[UIFont systemFontOfSize:14.0]];
        [fetchingLabel setTextAlignment:NSTextAlignmentCenter];
        [fetchingLabel setText: @"Searching for nearby locations"];
        [fetchingLocationsView addSubview:fetchingLabel];
        
        _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _spinner.center = CGPointMake(self.view.frame.size.width / 2, 50);
        [_spinner startAnimating];
        [fetchingLocationsView addSubview:_spinner];
        
        [self.view addSubview:fetchingLocationsView];
    }
    
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [_tableView reloadData];
	
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

@end
