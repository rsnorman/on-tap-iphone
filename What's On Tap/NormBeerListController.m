//
//  NormBeerListController.m
//  What's On Tap
//
//  Created by Ryan Norman on 11/28/13.
//  Copyright (c) 2013 Ryan Norman. All rights reserved.
//

#import "NormBeerListController.h"
#import "NormLocationFinderController.h"
#import "NormModalTransitionDelegate.h"
#import "NormLocationFinderDelegate.h"
#import "Reachability.h"
#import "Location.h"
#import "User.h"
#import <QuartzCore/QuartzCore.h>

@interface NormBeerListController () <UITableViewDataSource, UITableViewDelegate, UITabBarDelegate, UISearchDisplayDelegate, UISearchBarDelegate, NormLocationFinderDelegate>
@end

@implementation NormBeerListController

@synthesize managedObjectContext;

Location *_currentLocation;
User *_currentUser;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [self initWithStyle:style];
    if (self) {
        _currentLocation = [[Location alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    id appDelegate = (id)[[UIApplication sharedApplication] delegate];
    self.managedObjectContext = [appDelegate managedObjectContext];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self createNavigationController];
    
    [self createTableViewController];
    
    [self createSpinner];
    
    [self createMenu];
    
    _currentUser = [User current];
    _currentLocation = _currentUser.currentLocation;
    
    /*
     Observe the kNetworkReachabilityChangedNotification. When that notification is posted, the method reachabilityChanged will be called.
     */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    self.internetReachability = [Reachability reachabilityForInternetConnection];
    [self.internetReachability startNotifier];
    
    // Check to make sure there is a internet connection
    if ([self connectedToNetwork]) {
        
        // Load users last location
        if (_currentLocation != nil) {
            [self createLocationMenu];
            [self.spinnerView setMessage:[NSString stringWithFormat:@"Grabbing menu for\n%@", _currentLocation.name]];
            [self startFetchingAvailableMenu];
        }
        // Allow user to select a location nearby
        else {
            [self showSelectLocationModal];
        }
    }
    // Let user know they need to connect to the internet
    else {
        [self.spinnerView stopAnimating];
        [self.spinnerView setMessage:@"Please connect to the Internet"];
    }
}

/*!
 * Called by Reachability whenever status changes.
 */
- (void) reachabilityChanged:(NSNotification *)note
{
    if ([self connectedToNetwork]) {
        if (_currentLocation != nil) {
            [self createLocationMenu];
            [self.spinnerView setMessage:[NSString stringWithFormat:@"Grabbing menu for\n%@", _currentLocation.name]];
            [self.spinnerView startAnimating];
            [self startFetchingAvailableMenu];
        } else {
            [self showSelectLocationModal];
        }
    }
}

- (void) showSelectLocationModal
{
    NormLocationFinderController *locationFinder = [[NormLocationFinderController alloc] init];
    NormModalTransitionDelegate *transitionController = [[NormModalTransitionDelegate alloc] init];
    [transitionController setDuration: 0.25f];
    [transitionController setZoomOutPercentage:0.85f];
    [locationFinder setTransitioningDelegate:transitionController];
    [locationFinder setDelegate:self];
    self.modalPresentationStyle = UIModalPresentationCustom;
    [self presentViewController:locationFinder animated:YES completion:nil];
}

- (void) setLocation:(Location *)location
{
    if (![_currentLocation.lID isEqualToString: location.lID]) {
        
        if (_currentLocation != nil) {
            self.spinnerView.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height + 1);
            [self.spinnerView startAnimating];
            [self.spinnerView setHidden:NO];
            
            [UIView animateWithDuration:0.3
                                  delay:0.0
                                options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut
                             animations:^
             {
                 self.tableView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
             }
                             completion:nil];
            
            [UIView animateWithDuration:0.5
                                  delay:0.5
                 usingSpringWithDamping:0.6
                  initialSpringVelocity:4.0
                                options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut
                             animations:^
             {
                 self.spinnerView.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
             }
                             completion:nil];
            
        }
        
        _currentLocation = location;
        self.currentServeType = nil;
        
        [_currentUser setCurrentLocation:location];
        [_currentUser save];
        
        [self createLocationMenu];
        
        if (_currentLocation != nil) {
            [self.spinnerView setMessage:[NSString stringWithFormat:@"Grabbing menu for\n%@", _currentLocation.name]];
        }
        
        [self performSelector:@selector(startFetchingAvailableMenu) withObject:nil afterDelay:1.0];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    [UIView animateWithDuration:0.7
                          delay:0.2
         usingSpringWithDamping:0.6
          initialSpringVelocity:4.0
                        options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut
                     animations:^
     {
         self.spinnerView.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
     }
                     completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)startFetchingAvailableMenu
{
    if (_currentLocation == nil) {
        [self showErrorWithMessage:@"Select a location from the menu"];
        return;
    }
    // Fetch beers from server
    [Menu fetchForLocation:_currentLocation.lID success: ^(Menu *beerMenu) {
        self.beerMenu = beerMenu;
        
        if (self.currentServeType == nil){
            self.currentServeType = [self.beerMenu.serveTypeKeys objectAtIndex:0];
            [self performSelectorOnMainThread:@selector(setMenuButton) withObject:nil waitUntilDone:NO];
        }
        
        self.currentBeerStyles = [self.beerMenu getBeerStylesForServeType:self.currentServeType];
        self.currentBeersGroupedByStyle = [self.beerMenu getBeersGroupedByStyleForServeType:self.currentServeType];
        
        [self performSelectorOnMainThread:@selector(didFinishReceivingMenu) withObject:nil waitUntilDone:NO];
    } failedWithError:^(NSError *error) {
        
       NSString *errorMessage = [NSString stringWithFormat: @"Sorry, there was a problem grabbing the menu for \n%@. \nKegs must be tapped.", _currentLocation.name];
        [self performSelectorOnMainThread:@selector(showErrorWithMessage:) withObject: errorMessage waitUntilDone:NO];
    }];
}

- (void)showErrorWithMessage:(NSString *)errorMessage
{
    [self.spinnerView setMessage:errorMessage];
    [self.spinnerView stopAnimating];
}

- (void)refreshMenu
{
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Updating Menu..."];
    
    // Fetch beers from server
    [Menu refreshForLocation:_currentLocation.lID success: ^(Menu *beerMenu) {
        self.beerMenu = beerMenu;
        
        if (self.currentServeType == nil){
            self.currentServeType = [self.beerMenu.serveTypeKeys objectAtIndex:0];
            [self performSelectorOnMainThread:@selector(setMenuButton) withObject:nil waitUntilDone:NO];
        }
        
        self.currentBeerStyles = [self.beerMenu getBeerStylesForServeType:self.currentServeType];
        self.currentBeersGroupedByStyle = [self.beerMenu getBeersGroupedByStyleForServeType:self.currentServeType];
        
        [self performSelectorOnMainThread:@selector(didFinishReceivingMenu) withObject:nil waitUntilDone:NO];
    } failedWithError:^(NSError *error) {
        [self performSelectorOnMainThread:@selector(showErrorRefresh) withObject:nil waitUntilDone:NO];
    }];
}

- (void)showErrorRefresh
{
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"There was an error refreshing the menu"];
    [self performSelector:@selector(didFinishReceivingMenu) withObject:nil afterDelay:1.0];
}

- (void)loadBeersIntoTableView
{    
    [self.spinnerView stopAnimating];
    [self.spinnerView setHidden:YES];
    
    [self.tableView reloadData];
    self.tableView.hidden = NO;
    [self.refreshControl endRefreshing];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    
    
    [UIView animateWithDuration:0.5
                          delay:0.0
         usingSpringWithDamping:0.6
          initialSpringVelocity:4.0
                        options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut
                     animations:^
     {
         self.tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
     }
                     completion:nil];
}


- (void) didFinishReceivingMenu
{
    NSDateFormatter *inFormat = [[NSDateFormatter alloc] init];
    [inFormat setDateFormat:@"MMM dd H:mm a"];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat: @"Last Updated %@ \n Pull to Refresh",  [inFormat stringFromDate:self.beerMenu.createdOn] ]];
    [self createFilterMenu];
    [self loadBeersIntoTableView];
}


- (void)createNavigationController
{
    // Navigation Controller
    self.navigationController.navigationBar.barTintColor = _MAIN_COLOR;
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
    
    [[self.navigationController.navigationBar.subviews lastObject] setTintColor:[UIColor whiteColor]];
    
    
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc]
                                   initWithImage:[UIImage imageNamed:@"glass-button"]
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(toggleMenu)];
    
    
    self.navigationItem.leftBarButtonItem = menuButton;
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    
    UIView * container = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 90, 20)];
    UIButton * button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 90, 20)];
    [button addTarget:self action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"On Tap" forState:UIControlStateNormal];
    [[button titleLabel] setFont:[UIFont fontWithName:@"RhinoRaja" size:28]];
    [container addSubview:button];
    
    
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.navigationItem.titleView = container;
}

- (void)createTableViewController
{
    UITableViewController *tableViewController = [[UITableViewController alloc]initWithStyle:UITableViewStylePlain];
    [self addChildViewController:tableViewController];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh Beer List"];
    [self.refreshControl addTarget:self action:@selector(refreshMenu) forControlEvents:UIControlEventValueChanged];
    
    tableViewController.refreshControl = self.refreshControl;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, 320, self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height - self.navigationController.navigationBar.frame.origin.y) style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.hidden = YES;
    self.tableView.delegate = self;
    
    
    tableViewController.tableView = self.tableView;
    [self.view addSubview:self.tableView];
    
    
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
    
    self.tableView.tableHeaderView = _beerSearchBar;
}

- (void)createSpinner
{
    self.spinnerView = [[NormIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 200, 150)];
    self.spinnerView.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height + 10);
    [self.spinnerView setHidesWhenStopped:YES];
    [self.view addSubview:self.spinnerView];
}

-(void)createMenu
{
    self.menu = [[REMenu alloc] init];
    
    self.menu.appearsBehindNavigationBar = NO; // Affects only iOS 7
    self.menu.backgroundColor = _DARK_COLOR;
    self.menu.font = [UIFont fontWithName:_SECONDARY_FONT size:22];
    self.menu.subtitleFont = [UIFont fontWithName:_SECONDARY_FONT size:14];
    self.menu.textColor = [UIColor lightGrayColor];
    self.menu.separatorColor = [UIColor darkGrayColor];
    
    if (!REUIKitIsFlatMode()) {
        self.menu.cornerRadius = 4;
        self.menu.shadowRadius = 4;
        self.menu.shadowColor = [UIColor blackColor];
        self.menu.shadowOffset = CGSizeMake(0, 1);
        self.menu.shadowOpacity = 1;
    }
    
    self.menu.imageOffset = CGSizeMake(8, -1);
    self.menu.waitUntilAnimationIsComplete = NO;
    self.menu.badgeLabelConfigurationBlock = ^(UILabel *badgeLabel, REMenuItem *item) {
        badgeLabel.backgroundColor = _MAIN_COLOR;
        badgeLabel.layer.borderWidth = 0.0;
        badgeLabel.textColor = [UIColor whiteColor];
        badgeLabel.layer.cornerRadius = 10.0;
        badgeLabel.layer.frame = CGRectMake(25.0, 10.0, 20.0, 20.0);
    };
}


- (void)createFilterMenu
{
    __typeof (self) __weak weakSelf = self;

    NSMutableArray *menuItems = [[NSMutableArray alloc] init];

    
    for (NSString* serveType in self.beerMenu.serveTypeKeys)
    {
        UIImage * menuItemImage = nil;
        
        if ([serveType isEqual:@"On Tap"] || [serveType isEqual:@"Featured"] || [serveType isEqual:@"House"]) {
            menuItemImage = [UIImage imageNamed: @"glass-menu-item"];
        } else if([serveType isEqual:@"Bottles"]){
            menuItemImage = [UIImage imageNamed:@"bottle-menu-item"];
        }  else if([serveType isEqual:@"Cans"]){
            menuItemImage = [UIImage imageNamed:@"can-menu-item"];
        } else {
            menuItemImage = [UIImage imageNamed: @"glass-menu-item"];
        }
        
        
        REMenuItem *menuItem = [[REMenuItem alloc] initWithTitle:serveType
                                                              image:menuItemImage
                                                   highlightedImage:nil
                                                             action:^(REMenuItem *item) {
                                                                 
                                                                 if (![weakSelf.currentServeType isEqualToString:item.title]){
                                                                     weakSelf.currentServeType = item.title;
                                                                     weakSelf.currentBeerStyles = [weakSelf.beerMenu getBeerStylesForServeType:weakSelf.currentServeType];
                                                                     weakSelf.currentBeersGroupedByStyle = [weakSelf.beerMenu getBeersGroupedByStyleForServeType:weakSelf.currentServeType];
                                                                     
                                                                     [weakSelf setMenuButton];
                                                                     
                                                                     [weakSelf.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
                                                                     [weakSelf loadBeersIntoTableView];
                                                                 }
                                                             }];
        
        
        NSDictionary *beers = [self.beerMenu.serveTypes objectForKey:serveType];
        [menuItem setBadge:[NSString stringWithFormat:@"%lu", (unsigned long)beers.count]];

        [menuItems addObject:menuItem];
    }
    
    REMenuItem *locationMenuItem = [[REMenuItem alloc] initWithTitle:@"Locations"
                                                       image:nil
                                            highlightedImage:nil
                                                      action:^(REMenuItem *item) {
                                                          [weakSelf performSelector:@selector(showSelectLocationModal) withObject:nil afterDelay:0.5];                                                         
                                                      }];
    
    
    if (_currentLocation != nil) {
        [locationMenuItem setSubtitle:_currentLocation.name];
    }

    [menuItems addObject:locationMenuItem];
    
    [self.menu setItems:menuItems];
}

- (void) createLocationMenu
{
    __typeof (self) __weak weakSelf = self;
    
    NSMutableArray *menuItems = [[NSMutableArray alloc] init];
    
    REMenuItem *locationMenuItem = [[REMenuItem alloc] initWithTitle:@"Locations"
                                                               image:nil
                                                    highlightedImage:nil
                                                              action:^(REMenuItem *item) {
                                                                  [weakSelf performSelector:@selector(showSelectLocationModal) withObject:nil afterDelay:0.5];
                                                              }];
    
    
    if (_currentLocation != nil) {
        [locationMenuItem setSubtitle:_currentLocation.name];
    }
    
    [menuItems addObject:locationMenuItem];
    
    [self.menu setItems:menuItems];
}


- (void)setMenuButton
{
    UIImage * menuButtonImage = nil;
    
    if ([self.currentServeType isEqual:@"On Tap"]) {
        menuButtonImage = [UIImage imageNamed: @"glass-button"];
    } else if([self.currentServeType isEqual:@"Bottles"]){
        menuButtonImage = [UIImage imageNamed:@"bottle-button"];
    }  else if([self.currentServeType isEqual:@"Cans"]){
        menuButtonImage = [UIImage imageNamed:@"can-button"];
    } else {
        menuButtonImage = [UIImage imageNamed: @"glass-button"];
    }
    
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc]
                                   initWithImage:menuButtonImage
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(toggleMenu)];
    
    
    self.navigationItem.leftBarButtonItem = menuButton;
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
}

- (void)toggleMenu
{
    if (self.menu.isOpen)
        return [self.menu close];
    
    [self.menu showFromNavigationController:self.navigationController];
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
    
    NormBeerViewController *nbvc = [[NormBeerViewController alloc] init];
    [nbvc setBeer:beer];

    [self.navigationController pushViewController:nbvc animated:YES];
    
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


// Search Delegate

// Applies a filter to the menu and reloads the table
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    
    if (searchString.length > 0) {
        NSMutableDictionary *filteredBeersGroupedByStyle = [[NSMutableDictionary alloc] init];
        for (NSString *style in self.currentBeerStyles)
        {
            NSMutableArray * matchingBeers = [[NSMutableArray alloc] init];
            for (Beer *beer in [self.currentBeersGroupedByStyle objectForKey:style]) {
            
                if ([beer.name rangeOfString:searchString options:NSCaseInsensitiveSearch].location != NSNotFound ) {
                    [matchingBeers addObject:beer];
                }
            }
            
            if (matchingBeers.count > 0) {
                [filteredBeersGroupedByStyle setValue:matchingBeers forKey:style];
            }
        }
        self.currentBeersGroupedByStyle = filteredBeersGroupedByStyle;
        self.currentBeerStyles = [self.currentBeersGroupedByStyle allKeys];
    } else {
        self.currentBeerStyles = [self.beerMenu getBeerStylesForServeType:self.currentServeType];
        self.currentBeersGroupedByStyle = [self.beerMenu getBeersGroupedByStyleForServeType:self.currentServeType];
    }
    
    return YES;
}

//  Removes the filter from the menu
- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller{
    self.currentBeerStyles = [self.beerMenu getBeerStylesForServeType:self.currentServeType];
    self.currentBeersGroupedByStyle = [self.beerMenu getBeersGroupedByStyleForServeType:self.currentServeType];
}

// Sets the cell height for the search results
- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView
{
    self.tableView.rowHeight = 75.0f; // or some other height
}

- (BOOL) connectedToNetwork
{
    BOOL isInternet = NO;
    Reachability* reachability = [Reachability reachabilityWithHostName:@"google.com"];
    NetworkStatus remoteHostStatus = [reachability currentReachabilityStatus];
    
    if(remoteHostStatus == NotReachable)
    {
        isInternet = NO;
    }
    else if (remoteHostStatus == ReachableViaWWAN)
    {
        isInternet = YES;
    }
    else if (remoteHostStatus == ReachableViaWiFi)
    {
        isInternet = YES;
    }
    return isInternet;
}

@end
