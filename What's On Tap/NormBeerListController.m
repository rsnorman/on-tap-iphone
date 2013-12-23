//
//  NormBeerListController.m
//  What's On Tap
//
//  Created by Ryan Norman on 11/28/13.
//  Copyright (c) 2013 Ryan Norman. All rights reserved.
//

#import "NormBeerListController.h"
#import "NormBeer.h"
#import "NormBeerViewController.h"
#import "NormBeerTableCell.h"
#import "NormMenuManager.h"
#import "NormWhatsOnTap.h"
#import "NormImageCache.h"
#import <QuartzCore/QuartzCore.h>

@interface NormBeerListController () <NormMenuManagerDelegate, UITableViewDataSource, UITableViewDelegate, UITabBarDelegate, UISearchDisplayDelegate, UISearchBarDelegate>
@property NSArray *allBeers;
@property NSString *currentServeType;
@property NSMutableDictionary *serveTypes;
@property NSMutableArray *serveTypeKeys;
@property NSMutableDictionary *styles;
@property NSArray *styleKeys;
@property NormMenuManager *menuManager;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, weak) IBOutlet UITabBar *tabBar;
@property (nonatomic, weak) IBOutlet UITabBarItem *tapItem;
@property UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSOperationQueue *queue;
@property NormImageCache *imageCache;

@property UISearchBar *beerSearchBar;
@property UISearchDisplayController *beerSearchDisplayController;
@property NSMutableDictionary *beerSearchData;
@property (strong, readwrite, nonatomic) REMenu *menu;
@end

@implementation NormBeerListController


- (void)startFetchingAvailableMenu
{
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Updating Menu..."];
    [self.menuManager fetchAvailableMenuAtLocation];
}

- (void)loadBeersIntoTableView
{    
    [self.spinner stopAnimating];
    [self.tableView reloadData];
    self.tableView.hidden = NO;
    [self.refreshControl endRefreshing];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

- (void)groupBeers:(NSString *)searchString
{
    for (NormBeer* beer in self.allBeers)
    {
        if (searchString.length == 0 || [beer.name rangeOfString:searchString options:NSCaseInsensitiveSearch].location != NSNotFound){
            if ([self.serveTypes objectForKey:beer.serveType] == nil){
                [self.serveTypes setObject:[[NSMutableArray alloc] init] forKey:beer.serveType];
                [self.serveTypeKeys addObject: beer.serveType];
            }
            
            
            [[self.serveTypes objectForKey:beer.serveType] addObject:beer];
        }
    }
}

- (void)didReceiveMenu:(NormMenu *)menu
{
    self.allBeers = [[NSArray alloc] init];
    self.serveTypes = [[NSMutableDictionary alloc] init];
    self.serveTypeKeys = [[NSMutableArray alloc] init];

    self.allBeers = menu.beers;
    
    [self groupBeers:@""];
    
    self.currentServeType = [self.serveTypeKeys objectAtIndex:0];
    [self groupBeerStylesInServeType:self.currentServeType containsStyle:nil];
    
    
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh Menu"];
    
//    [self.refreshControl performSelectorOnMainThread:@selector(setAttributedTitle) withObject:[[NSAttributedString alloc] initWithString:@"Updating Menu..."] waitUntilDone:NO];

    [self performSelectorOnMainThread:@selector(createFilterMenu) withObject:nil waitUntilDone:NO];
    
    [self performSelectorOnMainThread:@selector(loadBeersIntoTableView) withObject:nil waitUntilDone:NO];
}

- (void)groupBeerStylesInServeType:(NSString *)serveType containsStyle:(NSString *)style
{
    self.styles = [[NSMutableDictionary alloc] init];
    
    NSMutableArray * unOrderedStyleKeys = [[NSMutableArray alloc] init];
    NSArray *serveTypeBeers = [self.serveTypes objectForKey:serveType];
    
    for (NormBeer* beer in serveTypeBeers)
    {
        if ([beer.styleCategory isEqual:style] || style == nil) {
            
            if ([self.styles objectForKey:beer.styleCategory] == nil){
                [self.styles setObject:[[NSMutableArray alloc] init] forKey:beer.styleCategory];
                [unOrderedStyleKeys addObject:beer.styleCategory];
            }
            
            [[self.styles objectForKey:beer.styleCategory] addObject:beer];
        }
    }
    
    self.styleKeys = [unOrderedStyleKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}


- (void)fetchingMenuFailedWithError:(NSError *)error
{
    NSLog(@"Error %@; %@", error, [error localizedDescription]);
}


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [self initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set up delegates for grabbing beers from server
    self.menuManager = [[NormMenuManager alloc] init];
    self.menuManager.communicator = [[NormWhatsOnTap alloc] init];
    self.menuManager.communicator.delegate = self.menuManager;
    self.menuManager.delegate = self;
    
    
    
    // Navigation Controller
    NSArray *ver = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    if ([[ver objectAtIndex:0] intValue] >= 7) {
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.7];
//        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:198.0/255.0 green:56.0/255.0 blue:32.0/255.0 alpha:1.0];
        
        self.navigationController.navigationBar.translucent = YES;
    }else {
        self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.7];
    }
    
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:198.0/255.0 green:56.0/255.0 blue:32.0/255.0 alpha:1.0]}];
    
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:198.0/255.0 green:56.0/255.0 blue:32.0/255.0 alpha:1.0]} forState:UIControlStateNormal];
    
    [[self.navigationController.navigationBar.subviews lastObject] setTintColor:[UIColor colorWithRed:198.0/255.0 green:56.0/255.0 blue:32.0/255.0 alpha:1.0]];
    
    UIView * container = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 95, 20)];
    UIButton * button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 80, 20)];
    [button addTarget:self action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"On Tap" forState:UIControlStateNormal];
    [[button titleLabel] setFont:[UIFont boldSystemFontOfSize:20.0]];
    [container addSubview:button];
    
    UIButton * imageButton = [[UIButton alloc]initWithFrame:CGRectMake(80, 6, 14, 9)];
    [imageButton addTarget:self action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];
    [imageButton setImage:[UIImage imageNamed:@"down-arrow.png"] forState:UIControlStateNormal];
    [container addSubview:imageButton];
    
    [button setTitleColor:[UIColor colorWithRed:198.0/255.0 green:56.0/255.0 blue:32.0/255.0 alpha:1.0] forState:UIControlStateNormal];
//    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.navigationItem.titleView = container;

    
    //Table View
    UITableViewController *tableViewController = [[UITableViewController alloc]initWithStyle:UITableViewStylePlain];
    [self addChildViewController:tableViewController];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh Beer List"];
    [self.refreshControl addTarget:self action:@selector(startFetchingAvailableMenu) forControlEvents:UIControlEventValueChanged];
    
    tableViewController.refreshControl = self.refreshControl;
    [tableViewController.refreshControl addTarget:self action:@selector(startFetchingAvailableMenu) forControlEvents:UIControlEventValueChanged];
    
    self.tableView.hidden = YES;
    self.tableView.delegate = self;
    
    tableViewController.tableView = self.tableView;
    
    
    
    
    // Search Bar
    _beerSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    _beerSearchBar.placeholder = @"Search Beers";
    /*the search bar widht must be > 1, the height must be at least 44
     (the real size of the search bar)*/
    
    _beerSearchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:_beerSearchBar contentsController:self];
    /*contents controller is the UITableViewController, this let you to reuse
     the same TableViewController Delegate method used for the main table.*/
    
    _beerSearchDisplayController.delegate = self;
    _beerSearchDisplayController.searchResultsDataSource = self;
    _beerSearchDisplayController.searchResultsDelegate = self;
    //set the delegate = self. Previously declared in ViewController.h
    
    self.tableView.tableHeaderView = _beerSearchBar;
    
    
    
    // Image Cache
    self.imageCache = [[NormImageCache alloc] init];
    
    [self.spinner startAnimating];
    // Fetch beers from server
    [self startFetchingAvailableMenu];
}

- (void)createFilterMenu
{
    __typeof (self) __weak weakSelf = self;

    NSMutableArray *menuItems = [[NSMutableArray alloc] init];

    
    for (NSString* serveType in self.serveTypeKeys)
    {
        REMenuItem *menuItem = [[REMenuItem alloc] initWithTitle:serveType
                                                              image:nil
                                                   highlightedImage:[UIImage imageNamed:@"checkmark.png"]
                                                             action:^(REMenuItem *item) {
                                                                 for(REMenuItem * _item in weakSelf.menu.items){
                                                                     if ([_item.title isEqual:item.title]){
                                                                        [_item setImage:[UIImage imageNamed:@"checkmark.png"]];
                                                                        [_item setHiglightedImage:[UIImage imageNamed:@"checkmark.png"]];
                                                                     } else {
                                                                         [_item setImage:nil];
                                                                     }
                                                                 }
                                                
                                                                 weakSelf.currentServeType = item.title;
                                                                 [weakSelf groupBeerStylesInServeType: weakSelf.currentServeType containsStyle:nil];
                                                                 [weakSelf.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
                                                                 [weakSelf loadBeersIntoTableView];
                                                             }];
        
        
        NSArray *beers = [self.serveTypes objectForKey:serveType];
        [menuItem setSubtitle:[NSString stringWithFormat:@"%d Available Beers", beers.count]];

        [menuItems addObject:menuItem];
    }
    
    [[menuItems objectAtIndex:0] setImage:[UIImage imageNamed:@"checkmark.png"]];
    
    self.menu = [[REMenu alloc] initWithItems:menuItems];
    
    self.menu.appearsBehindNavigationBar = NO; // Affects only iOS 7
    self.menu.backgroundColor = [UIColor colorWithRed:42.0/255.0 green:39.0/255.0 blue:46.0/255.0 alpha:1.0];
    self.menu.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16];
    self.menu.textColor = [UIColor whiteColor];
    self.menu.separatorColor = [UIColor darkGrayColor];
    
    if (!REUIKitIsFlatMode()) {
        self.menu.cornerRadius = 4;
        self.menu.shadowRadius = 4;
        self.menu.shadowColor = [UIColor blackColor];
        self.menu.shadowOffset = CGSizeMake(0, 1);
        self.menu.shadowOpacity = 1;
    }
    
    self.menu.imageOffset = CGSizeMake(5, -1);
    self.menu.waitUntilAnimationIsComplete = NO;
    self.menu.badgeLabelConfigurationBlock = ^(UILabel *badgeLabel, REMenuItem *item) {
        badgeLabel.backgroundColor = [UIColor whiteColor];
        badgeLabel.layer.borderColor = [UIColor darkGrayColor].CGColor;
        badgeLabel.textColor = [UIColor colorWithRed:198.0/255.0 green:56.0/255.0 blue:32.0/255.0 alpha:1.0];
        badgeLabel.layer.cornerRadius = 10.0;
        badgeLabel.layer.frame = CGRectMake(8.0, 10.0, 20.0, 20.0);
    };
}

- (void)toggleMenu
{
    if (self.menu.isOpen)
        return [self.menu close];
    
    [self.menu showFromNavigationController:self.navigationController];
}

- (void)filterBeerStyle:(NSString *)style
{
    [self groupBeerStylesInServeType:self.currentServeType containsStyle:style];
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
        return self.styleKeys.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[self.styles valueForKey:[self.styleKeys objectAtIndex:section]] count];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.styleKeys objectAtIndex:section];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *normTableCellIdentifier = @"NormBeerTableCell";
    
    NormBeerTableCell *cell = (NormBeerTableCell *)[tableView dequeueReusableCellWithIdentifier:normTableCellIdentifier];
    if (cell == nil)
    {
        cell = [[NormBeerTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:normTableCellIdentifier];
    }
    
    [cell setBeer:[[self.styles objectForKey: [self.styleKeys objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row]];
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 75;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView
{
    tableView.rowHeight = 75.0f; // or some other height
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NormBeer *beer = [[self.styles objectForKey: [self.styleKeys objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    
    NormBeerViewController *nbvc = [[NormBeerViewController alloc] init];
    [nbvc setBeer:beer];
    NSLog(@"Navigation Controller: %@", self.navigationController);
    [self.navigationController pushViewController:nbvc animated:YES];
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIColor *bgHeaderColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.9];
    UIColor *textColor = [UIColor colorWithRed:42.0/255.0 green:39.0/255.0 blue:46.0/255.0 alpha:1.0];
    
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

    
    headerLabel.text = [self.styleKeys objectAtIndex:section];
    [customView addSubview:headerLabel];
    
    UIView *topBorder = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 0.5)];
    UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0.0, 34.5, 320.0, 0.5)];

    topBorder.layer.borderColor = [UIColor lightGrayColor].CGColor;
    topBorder.layer.borderWidth = 1.0f;
    bottomBorder.layer.borderColor = [UIColor lightGrayColor].CGColor;
    bottomBorder.layer.borderWidth = 1.0f;
    
//    [customView addSubview:topBorder];
    [customView addSubview:bottomBorder];
    
    return customView;
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    self.currentServeType = item.title;
    [self groupBeerStylesInServeType: self.currentServeType containsStyle:nil];
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    [self loadBeersIntoTableView];
//    [self createFilterMenu];
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35.0;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self.serveTypes removeAllObjects];
    [self.serveTypeKeys removeAllObjects];
    [self groupBeers:searchString];
    [self groupBeerStylesInServeType:self.currentServeType];
    
    return YES;
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller{
    [self.serveTypes removeAllObjects];
    [self.serveTypeKeys removeAllObjects];
    [self groupBeers:@""];
    [self groupBeerStylesInServeType:self.currentServeType];
}

@end
