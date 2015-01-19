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

@interface NormBeerTableViewController () <UISearchBarDelegate, UISearchDisplayDelegate>
@property NSDictionary *unfilteredBeers;
@property NSArray *unfilteredGroups;

@end

@implementation NormBeerTableViewController



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
    self.currentBeersGrouped = beers;
    
    NSMutableArray *sortedGroups = [[NSMutableArray alloc] initWithArray:[[beers allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
    
    
    [sortedGroups removeObject:@"New"];
    
    if (((NSArray *)[self.currentBeersGrouped objectForKey:@"New"]).count > 0) {
        [sortedGroups insertObject:@"New" atIndex:0];
    }
    
    self.currentBeerGroups = sortedGroups;
    
    [self.tableView reloadData];
    self.tableView.hidden = NO;
    
    if (self.currentBeersGrouped.count > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
}

// Table View Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.currentBeerGroups.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[self.currentBeersGrouped valueForKey:[self.currentBeerGroups objectAtIndex:section]] count];
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
    
    if ([_groupName isEqualToString:@"styleCategory"]) {
        [cell setSecondaryLabelField:@"breweryName"];
    } else {
        [cell setSecondaryLabelField:@"style"];
    }
    
    beerStyle = [self.currentBeerGroups objectAtIndex:indexPath.section];
    beer = [[self.currentBeersGrouped objectForKey: beerStyle] objectAtIndex:indexPath.row];
    [cell setBeer:beer];
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 75;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *beerStyle = [self.currentBeerGroups objectAtIndex:indexPath.section];
    
    Beer *beer = [[self.currentBeersGrouped objectForKey: beerStyle] objectAtIndex:indexPath.row];
    
    
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
    
    UIView *topBorder = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 0.5)];
    UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0.0, 34.5, 320.0, 0.5)];
    
    if (section != 0) {
        [topBorder.layer setBorderColor:[UIColor lightGrayColor].CGColor];
        [topBorder.layer setBorderWidth:0.5];
        [topBorder setClipsToBounds:YES];
    }
    
    bottomBorder.layer.borderColor = [UIColor lightGrayColor].CGColor;
    bottomBorder.layer.borderWidth = 0.5;
    bottomBorder.clipsToBounds = YES;
    
    [customView addSubview:topBorder];
    [customView addSubview:bottomBorder];
    
    // create the button object
    UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    headerLabel.opaque = NO;
    headerLabel.textColor = textColor;
    headerLabel.highlightedTextColor = textColor;
    headerLabel.font = [UIFont boldSystemFontOfSize:14];
    headerLabel.frame = CGRectMake(5.0, 0.0, 300.0, 35.0);
    
    headerLabel.text = [self.currentBeerGroups objectAtIndex:section];
    [customView addSubview:headerLabel];
        
    return customView;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([((NSString *)[self.currentBeerGroups objectAtIndex:section]) isEqualToString: @"None"] ) {
        return 0.0;
    } else {
        return 35.0;
    }
}


- (void) showTableViewWithAnimate:(BOOL)animated completion:(void (^)(BOOL isComplete))completionAction
{
    if (animated) {
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
    } else {
        self.tableView.frame = CGRectMake(0, 0, self.tableView.frame.size.width, self.tableView.frame.size.height);
        completionAction(YES);
    }
    
}

- (void) hideTableViewWithAnimate:(BOOL)animated completion:(void (^)(BOOL isComplete))completionAction
{
    [UIView animateWithDuration:0.3
                          delay:0.0
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
        NSMutableDictionary *filteredBeersGrouped = [[NSMutableDictionary alloc] init];
        for (NSString *group in _unfilteredGroups)
        {
            NSMutableArray * matchingBeers = [[NSMutableArray alloc] init];
            for (Beer *beer in [_unfilteredBeers objectForKey:group]) {
                
                if ([beer.name rangeOfString:searchString options:NSCaseInsensitiveSearch].location != NSNotFound ) {
                    [matchingBeers addObject:beer];
                }
            }
            
            if (matchingBeers.count > 0) {
                [filteredBeersGrouped setValue:matchingBeers forKey:group];
            }
        }
        
        [self setBeers:filteredBeersGrouped];
    } else {
        [self setBeers:_unfilteredBeers];
    }
    
    return YES;
}

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller
{
    _unfilteredBeers = self.currentBeersGrouped;
    _unfilteredGroups = self.currentBeerGroups;
}

//  Removes the filter from the menu
- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller{
    [self setBeers:_unfilteredBeers];
    
    _unfilteredGroups = nil;
    _unfilteredBeers = nil;
    
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
}

// Sets the cell height for the search results
- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView
{
    self.tableView.rowHeight = 75.0f; // or some other height
}

@end
