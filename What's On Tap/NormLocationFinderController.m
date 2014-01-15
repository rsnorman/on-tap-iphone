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

@interface NormLocationFinderController () <NormModalControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@end

@implementation NormLocationFinderController

NSMutableArray *_locations;
UITableView *_tableView;

- (id)init
{
    self = [super init];
    
    if (self) {
        _locations = [[NSMutableArray alloc] init];
        
        NSArray *locationsJSON = @[@{@"name": @"Whichcraft Taproom", @"id": @"11580", @"type": @"Bar", @"address": @"124 Ashman St. Midland, MI 4864"}];
        
        for(NSDictionary *locationDic in locationsJSON) {
            NormLocation *location = [[NormLocation alloc] init];
            for (NSString *key in locationDic) {
                if ([location respondsToSelector:NSSelectorFromString(key)]) {
                    [location setValue:[locationDic valueForKey:key] forKey:key];
                }
            }
            
            [_locations addObject:location];
        }
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
    
    return cell;
}

@end
