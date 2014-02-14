//
//  NormLocationTableViewController.m
//  On Tap
//
//  Created by Ryan Norman on 2/8/14.
//  Copyright (c) 2014 Ryan Norman. All rights reserved.
//

#import "NormLocationTableViewController.h"
#import "NormLocationCell.h"
#import "Location.h"

@interface NormLocationTableViewController () <NormLocationCellDelegate>

@end

@implementation NormLocationTableViewController

NSArray *locations;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        locations = [[NSArray alloc] init];
        self.displayCount = 0;
    }
    return self;
}

- (void)setLocations:(NSArray *)_locations
{
    locations = _locations;
    
    [self setIsAnimating:YES];
    [self setDelayCellDisplay:YES];
    [self.tableView reloadData];
    
    [self performSelector:@selector(setDelayCellDisplay:) withObject:NO afterDelay:0.1];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [locations count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *normTableCellIdentifier = @"NormLocationCell";
    
    NormLocationCell *cell = (NormLocationCell *)[tableView dequeueReusableCellWithIdentifier:normTableCellIdentifier];
    if (cell == nil)
    {
        cell = [[NormLocationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:normTableCellIdentifier];
        cell.delegate = self;
    }
    
    [cell setLocation:[locations objectAtIndex:indexPath.row]];
    
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
    if ([self.delegate respondsToSelector:@selector(didSelectLocation:)]) {
        [self.delegate didSelectLocation:(Location *)[locations objectAtIndex:indexPath.row]];
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (void) didSelectLocationMap:(Location *)location
{
    [self.delegate didSelectLocationMap:location];
}
@end
