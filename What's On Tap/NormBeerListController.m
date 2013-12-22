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

- (void)addServeTypeTabBarItems:(NSArray *)serveTypes
{
//    NSMutableArray *tabBarItems = [[NSMutableArray alloc]init];
//    for (NSString *serveType in serveTypes) {
//        UINavigationController *barItem = [[UINavigationController alloc] init];
//        barItem.tabBarItem.title = serveType;
//        barItem.navigationItem.title = serveType;
//        [tabBarItems addObject:barItem];
//    }
//    
//    self.tabBarController.viewControllers = tabBarItems;
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
        self.navigationController.navigationBar.translucent = YES;
    }else {
        self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.7];
    }
    
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:198.0/255.0 green:56.0/255.0 blue:32.0/255.0 alpha:1.0]}];
    
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:198.0/255.0 green:56.0/255.0 blue:32.0/255.0 alpha:1.0]} forState:UIControlStateNormal];
    
    [[self.navigationController.navigationBar.subviews lastObject] setTintColor:[UIColor colorWithRed:198.0/255.0 green:56.0/255.0 blue:32.0/255.0 alpha:1.0]];
    
    
    
    
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
    
    
    // Tab Bar
    self.tabBar.delegate = self;
    
    [[UITabBar appearance] setTintColor:[UIColor colorWithRed:198.0/255.0 green:56.0/255.0 blue:32.0/255.0 alpha:1.0]];
    
    [self.tabBar setSelectedItem: self.tapItem];
    
    
    
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
    int allCount = 0;
    
    REMenuItem *menuItem = [[REMenuItem alloc] initWithTitle:@"All"
                                                       image:nil
                                            highlightedImage:nil
                                                      action:^(REMenuItem *item) {
                                                          NSLog(@"Item: %@", item);
                                                          [weakSelf filterBeerStyle:nil];
                                                      }];
    
    [menuItems addObject:menuItem];
    
    for (NSString* style in self.styleKeys)
    {
        REMenuItem *menuItem = [[REMenuItem alloc] initWithTitle:style
                                                              image:nil
                                                   highlightedImage:nil
                                                             action:^(REMenuItem *item) {
                                                                 NSLog(@"Item: %@", item);
                                                                 [weakSelf filterBeerStyle:item.title];
                                                             }];
        
        
        NSArray *styles = [self.styles objectForKey:style];
        menuItem.badge = [NSString stringWithFormat: @"%d", styles.count];
        
        allCount = allCount + styles.count;
        
        [menuItems addObject:menuItem];
    }
    
    menuItem.badge = [NSString stringWithFormat:@"%d", allCount];
    
    
    self.menu = [[REMenu alloc] initWithItems:menuItems];
    
    self.menu.appearsBehindNavigationBar = NO; // Affects only iOS 7
    self.menu.backgroundColor = [UIColor colorWithRed:42.0/255.0 green:39.0/255.0 blue:46.0/255.0 alpha:1.0];
    self.menu.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16];
    self.menu.textColor = [UIColor whiteColor];
//    self.menu.separatorColor = [UIColor whiteColor];
    
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
        badgeLabel.layer.borderColor = [UIColor whiteColor].CGColor;
        badgeLabel.textColor = [UIColor colorWithRed:198.0/255.0 green:56.0/255.0 blue:32.0/255.0 alpha:1.0];
        badgeLabel.layer.cornerRadius = 10.0;
        badgeLabel.layer.frame = CGRectMake(8.0, 10.0, 20.0, 20.0);
    };
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Styles" style:UIBarButtonItemStyleBordered target:self action:@selector(toggleMenu)];
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
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"BeerTableCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    NormBeer *beer = [[self.styles objectForKey: [self.styleKeys objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    
    cell.nameLabel.text = beer.name;
    cell.breweryLabel.text = beer.breweryName;
    cell.costLabel.text = [NSString stringWithFormat:@"$%g", beer.price];
    cell.detailsLabel.text = [[NSArray arrayWithObjects:beer.servedIn, @" - ", [NSString stringWithFormat:@"%g%% ABV", beer.abv], nil] componentsJoinedByString:@" "];
    
    CALayer *imageLayer = cell.imageView.layer;
    [imageLayer setCornerRadius:30];
    [imageLayer setBorderWidth:1];
    [imageLayer setBorderColor:[UIColor colorWithRed:201.0/255.0 green:201.0/255.0 blue:201.0/255.0 alpha:1.0].CGColor];
    [imageLayer setMasksToBounds:YES];
    
    CALayer *priceLayer = cell.costLabel.layer;
    [priceLayer setCornerRadius:15];
    [cell.costLabel setBackgroundColor:[UIColor colorWithRed:198.0/255.0 green:56.0/255.0 blue:32.0/255.0 alpha:1.0]];
    
    [priceLayer setMasksToBounds:YES];
    
    if (beer.label.length != 0){
        
        UIImage *image = [self.imageCache imageForKey:beer.label];
        
        if (image)
        {
            cell.imageView.image = image;
        }
        else {
            
            if ([beer.serveType  isEqual: @"On Tap"]) {
                [cell.imageView setImage:[UIImage imageNamed: @"tap-highlight.png"]];
            } else if ([beer.serveType  isEqual: @"Bottles"]) {
                [cell.imageView setImage:[UIImage imageNamed: @"bottle-highlight.png"]];
            } else {
                [cell.imageView setImage:[UIImage imageNamed: @"can-highlight.png"]];
            }
                
            // get the UIImage
            [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:beer.label]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                cell.imageView.image = [UIImage imageWithData:data];
                [self.imageCache setImage:cell.imageView.image forKey:beer.label];
            }];
        }
    } else {
        if ([beer.serveType  isEqual: @"On Tap"]) {
            [cell.imageView setImage:[UIImage imageNamed: @"tap-highlight.png"]];
        } else if ([beer.serveType  isEqual: @"Bottles"]) {
            [cell.imageView setImage:[UIImage imageNamed: @"bottle-highlight.png"]];
        } else {
            [cell.imageView setImage:[UIImage imageNamed: @"can-highlight.png"]];
        }
    }
    
    
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
    NSLog(@"Selected Row");
    NormBeer *beer = [[self.styles objectForKey: [self.styleKeys objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    
    NormBeerViewController *nbvc = [self.storyboard instantiateViewControllerWithIdentifier:@"BeerViewController"];
    nbvc.beer = beer;
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
    [self createFilterMenu];
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
