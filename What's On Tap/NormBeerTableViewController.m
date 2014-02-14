//
//  NormBeerTableViewController.m
//  On Tap
//
//  Created by Ryan Norman on 2/9/14.
//  Copyright (c) 2014 Ryan Norman. All rights reserved.
//

#import "NormBeerTableViewController.h"
#import "NormBeerTableCell.h"
#import "Beer.h"
#import "NormBeerViewController.h"
#import "TestFlight.h"

@interface NormBeerTableViewController () <UISearchBarDelegate, UISearchDisplayDelegate>

@end

@implementation NormBeerTableViewController

NSDictionary *unfilteredBeers;
NSArray *unfilteredStyles;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)setTableView:(UITableView *)tableView
{
    [super setTableView:tableView];
    self.tableView.tableHeaderView = self.beerSearchBar;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setBeers:(NSDictionary *)beers
{
    self.currentBeersGroupedByStyle = beers;
    self.currentBeerStyles = [[beers allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    [self.tableView reloadData];
    self.tableView.hidden = NO;
    
    if (self.currentBeersGroupedByStyle.count > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
}

// Table View Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.currentBeerStyles.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[self.currentBeersGroupedByStyle valueForKey:[self.currentBeerStyles objectAtIndex:section]] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *normTableCellIdentifier = @"NormBeerTableCell";
    
    NormBeerTableCell *cell = (NormBeerTableCell *)[tableView dequeueReusableCellWithIdentifier:normTableCellIdentifier];
    NSString *beerStyle;
    Beer *beer;
    
    if (cell == nil)
    {
        cell = [[NormBeerTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:normTableCellIdentifier];
    }
    
    beerStyle = [self.currentBeerStyles objectAtIndex:indexPath.section];
    beer = [[self.currentBeersGroupedByStyle objectForKey: beerStyle] objectAtIndex:indexPath.row];
    [cell setBeer:beer];
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 75;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *beerStyle = [self.currentBeerStyles objectAtIndex:indexPath.section];
    
    Beer *beer = [[self.currentBeersGroupedByStyle objectForKey: beerStyle] objectAtIndex:indexPath.row];
    
    
    if ([self.delegate respondsToSelector:@selector(didSelectBeer:)]) {
        [self.delegate didSelectBeer:beer];
    }
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIColor *bgHeaderColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.9];
    UIColor *textColor = _DARK_COLOR;
    
    // create the parent view that will hold header Label
    UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 35.0)];
    customView.backgroundColor = bgHeaderColor;
    
    // create the button object
    UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    headerLabel.opaque = NO;
    headerLabel.textColor = textColor;
    headerLabel.highlightedTextColor = textColor;
    headerLabel.font = [UIFont boldSystemFontOfSize:14];
    headerLabel.frame = CGRectMake(5.0, 0.0, 300.0, 35.0);
    
    
    headerLabel.text = [self.currentBeerStyles objectAtIndex:section];
    [customView addSubview:headerLabel];
    
    UIView *topBorder = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 0.5)];
    UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0.0, 34.5, 320.0, 0.5)];
    
    topBorder.layer.borderColor = [UIColor lightGrayColor].CGColor;
    topBorder.layer.borderWidth = 1.0f;
    bottomBorder.layer.borderColor = [UIColor lightGrayColor].CGColor;
    bottomBorder.layer.borderWidth = 1.0f;
    
    [customView addSubview:topBorder];
    [customView addSubview:bottomBorder];
    
    return customView;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35.0;
}


- (void) showTableViewWithAnimate:(BOOL)animated completion:(void (^)(BOOL isComplete))completionAction
{
    [UIView animateWithDuration:0.5
                          delay:0.0
         usingSpringWithDamping:0.6
          initialSpringVelocity:4.0
                        options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut
                     animations:^
     {
         self.tableView.frame = CGRectMake(0, 0, self.tableView.frame.size.width, self.tableView.frame.size.height);
     }
                     completion:completionAction];
}

- (void) hideTableViewWithAnimate:(BOOL)animated completion:(void (^)(BOOL isComplete))completionAction
{
    [UIView animateWithDuration:0.5
                          delay:0.0
         usingSpringWithDamping:0.6
          initialSpringVelocity:4.0
                        options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut
                     animations:^
     {
         self.tableView.frame = CGRectOffset(self.tableView.frame, 0, self.tableView.frame.size.height);
     }
                     completion:completionAction];
}

// Search Delegate

// Applies a filter to the menu and reloads the table
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    
    if (searchString.length > 0) {
        NSMutableDictionary *filteredBeersGroupedByStyle = [[NSMutableDictionary alloc] init];
        for (NSString *style in unfilteredStyles)
        {
            NSMutableArray * matchingBeers = [[NSMutableArray alloc] init];
            for (Beer *beer in [unfilteredBeers objectForKey:style]) {
                
                if ([beer.name rangeOfString:searchString options:NSCaseInsensitiveSearch].location != NSNotFound ) {
                    [matchingBeers addObject:beer];
                }
            }
            
            if (matchingBeers.count > 0) {
                [filteredBeersGroupedByStyle setValue:matchingBeers forKey:style];
            }
        }
        
        [self setBeers:filteredBeersGroupedByStyle];
    } else {
        [self setBeers:unfilteredBeers];
    }
    
    return YES;
}

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller
{
    unfilteredBeers = self.currentBeersGroupedByStyle;
    unfilteredStyles = self.currentBeerStyles;
    
    [TestFlight passCheckpoint:@"Searched Beers"];
}

//  Removes the filter from the menu
- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller{
    [self setBeers:unfilteredBeers];
    
    unfilteredStyles = nil;
    unfilteredBeers = nil;
}

// Sets the cell height for the search results
- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView
{
    self.tableView.rowHeight = 75.0f; // or some other height
}

@end
