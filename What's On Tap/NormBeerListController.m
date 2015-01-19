//
//  NormBeerListController.m
//  What's On Tap
//
//  Created by Ryan Norman on 11/28/13.
//  Copyright (c) 2013 Ryan Norman. All rights reserved.
//

#import "NormBeerListController.h"

#import "Location.h"
#import "User.h"

#import "NormSearchBar.h"

#import "NormLocationFinderController.h"
#import "NormModalTransitionDelegate.h"
#import "NormLocationFinderDelegate.h"
#import "NormBeerTableViewControllerDelegate.h"
#import "NormConnectionManagerDelegate.h"
#import "NormStyleMenuDelegate.h"
#import <QuartzCore/QuartzCore.h>

@interface NormBeerListController () <NormLocationFinderDelegate, NormConnectionManagerDelegate, NormBeerTableViewControllerDelegate, NormServeTypeMenuDelegate, NormDropDownMenuDelegate>

@property UILabel *locationNameLabel;
@property NSString *group;
@property NSString *sort;
@property Location *currentLocation;
@property User *currentUser;
@property BOOL menuLoaded;
@property BOOL menuIsLoading;
@property BOOL loadingPreviousMenu;
@property (nonatomic, retain) NormDropDownMenu *groupMenu;
@property (nonatomic, retain) NormDropDownMenu *sortMenu;
@end

@implementation NormBeerListController

@synthesize managedObjectContext;


- (id)initWithCoder:(NSCoder*)aDecoder
{
    if(self = [super initWithCoder:aDecoder])
    {
        _menuLoaded = NO;
        
        
        self.edgesForExtendedLayout = UIRectEdgeNone;
        
        _loadingPreviousMenu = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    _currentUser = [User current];
    _currentLocation = _currentUser.currentLocation;
    
    _group = _currentUser.groupPreference;
    if (_group == nil) {
        _group = @"styleCategory";
    }
    
    _sort = _currentUser.sortPreference;
    if (_sort == nil) {
        _sort = @"name";
    }
    
    [self createNavigationController];
    
    [self createTableViewController];
    
    [self createSpinner];
    
    [self createMenu];
    
    
    [self.view setBackgroundColor:_DARK_COLOR];
    [self.view addSubview:self.locationNameLabel];
    [self.view bringSubviewToFront:self.locationNameLabel];
    

    self.connectionManager = [[NormConnectionManager alloc] init];
    [self.connectionManager setDelegate:self];
}

- (BOOL) loadCurrentMenu
{
    self.beerMenu = [Menu getCurrentForLocation:_currentLocation.lID];
    
    // Fetch beers from server
    
    if (self.beerMenu != nil) {
        if (self.currentServeType == nil){
            self.currentServeType = [self.beerMenu.serveTypeKeys objectAtIndex:0];
            [self performSelectorOnMainThread:@selector(setMenuButton) withObject:nil waitUntilDone:NO];
        }
        
        Menu *lastMenu = [Menu getLastForLocation:_currentLocation.lID];
        
        if (lastMenu != nil) {
            [self.beerMenu flagNewBeersSinceLastMenu: lastMenu];
        }
        
        [self didFinishReceivingMenu];
        
        return YES;
    } else {
        return NO;
    }
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.connectionManager performSelectorInBackground:@selector(checkForConnection) withObject:nil];
    [self performSelector:@selector(stillCheckingForNetworkConnection) withObject:nil afterDelay:1.0];
    
    // Load users last location
    if (_currentLocation != nil) {
        _loadingPreviousMenu = YES;
        if (![self loadCurrentMenu] ) {
            _loadingPreviousMenu = NO;
            [self.spinnerView setMessage:[NSString stringWithFormat:@"Grabbing menu for\n%@", _currentLocation.name]];
            [self.spinnerView startAnimating];
            [self setLocation:_currentLocation];
        } else {
            [self.spinnerView setHidden:YES];
        }
    }
}

- (void) stillCheckingForNetworkConnection
{
    if (self.connectionManager.isCheckingConnection) {
        
        // Load users last location
        if (_currentLocation != nil) {            
            [self.menu performSelectorOnMainThread:@selector(setLocation:) withObject:_currentLocation waitUntilDone:NO];
            
            [self.spinnerView performSelectorOnMainThread:@selector(setMessage:) withObject:[NSString stringWithFormat:@"Grabbing menu for\n%@", _currentLocation.name] waitUntilDone:NO];
        }
    }
}

/*!
 * Called by Reachability whenever status changes.
 */
- (void) didConnectToNetwork
{
    if (_currentLocation != nil) {
        if (!_menuLoaded) {
            [self.menu performSelectorOnMainThread:@selector(setLocation:) withObject:_currentLocation waitUntilDone:NO];
            [self performSelectorOnMainThread:@selector(startFetchingAvailableMenu) withObject:nil waitUntilDone:NO];
        } else {
            [self performSelectorOnMainThread:@selector(setRefreshControlMenuText) withObject:nil waitUntilDone:NO];
        }
    } else {
        [self performSelectorOnMainThread:@selector(showSelectLocationFinder) withObject:nil waitUntilDone:NO];
    }
}
- (void) didDisconnectFromNetwork
{
    if (!_menuLoaded) {
        [self performSelectorOnMainThread:@selector(showNoInternetConnection) withObject:nil waitUntilDone:NO];
    }
}

- (void)showNoInternetConnection
{
    [self.spinnerView setErrorMessage:@"Please connect to the Internet"];
}

- (void) didSelectBeer:(Beer *)beer
{
    NormBeerViewController *nbvc = [[NormBeerViewController alloc] init];
    [nbvc setBeer:beer];

    [self.navigationController pushViewController:nbvc animated:YES];
}

- (void) didSelectServeType:(NSString *)serveType
{
    if (![self.currentServeType isEqualToString:serveType]){
        self.currentServeType = serveType;
        [self setMenuButton];
        [self loadBeersIntoTableView: [self.beerMenu getBeersGrouped:_group serveType:self.currentServeType sort:_sort]];
    }
}

- (void) didSelectLocationFinder
{
    [self performSelector:@selector(showSelectLocationFinder) withObject:nil afterDelay:0.5];
}

- (void) showSelectLocationFinder
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
        
        _currentLocation = location;
        self.currentServeType = nil;
        
        [_currentUser setCurrentLocation:location];
        [_currentUser save];
        
        if (_currentLocation != nil) {
            [self.spinnerView setMessage:[NSString stringWithFormat:@"Grabbing menu for\n%@", _currentLocation.name]];
            [self.spinnerView startAnimating];
            
            [self.beerTableViewController hideTableViewWithAnimate:YES completion:^(BOOL isComplete) {
                [self startFetchingAvailableMenu];
            }];
        }
    }
    
    [self.menu setLocation:_currentLocation]; // Make sure this menu is set
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)startFetchingAvailableMenu
{
    if (_menuIsLoading) {
        return;
    }
    
    _menuLoaded = NO;
    
    if (_currentLocation == nil) {
        [self showErrorWithMessage:@"Select a location from the menu"];
        return;
    }
    
    if (![self loadCurrentMenu]) {
        
        if (!self.connectionManager.isConnectedToInternet) {
            [self showErrorWithMessage:@"Please connect to the Internet"];
            return;
        }
        
        [self.menu setServeTypes:@[] withBeerCounts:@[]];
        
        NSLog(@"Start fetching location");
        _menuIsLoading = YES;
        [Menu fetchForLocation:_currentLocation.lID success: ^(Menu *beerMenu) {
            self.beerMenu = beerMenu;
            
            Menu *lastMenu = [Menu getLastForLocation:_currentLocation.lID];
            
            if (lastMenu != nil) {
                [self.beerMenu flagNewBeersSinceLastMenu: lastMenu];
            }
            
            if (self.currentServeType == nil){
                self.currentServeType = [self.beerMenu.serveTypeKeys objectAtIndex:0];
                [self performSelectorOnMainThread:@selector(setMenuButton) withObject:nil waitUntilDone:NO];
            }
            
            [self performSelectorOnMainThread:@selector(didFinishReceivingMenu) withObject:nil waitUntilDone:NO];
        } failedWithError:^(NSError *error) {
            
            NSString *errorMessage = [NSString stringWithFormat: @"Sorry, there was a problem grabbing the menu for \n%@. \n\nKegs must be busted.", _currentLocation.name];
            [self performSelectorOnMainThread:@selector(showErrorWithMessage:) withObject: errorMessage waitUntilDone:NO];
            _menuIsLoading = NO;
        }];
    }

}

- (void)showErrorWithMessage:(NSString *)errorMessage
{   
    [self.spinnerView setErrorMessage:errorMessage];
}

- (void)refreshMenu
{
    if (self.connectionManager.isConnectedToInternet) {
        self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Updating Menu..."];
        
        // Fetch beers from server
        [Menu refreshForLocation:_currentLocation.lID success: ^(Menu *beerMenu) {
            self.beerMenu = beerMenu;
            
            Menu *lastMenu = [Menu getLastForLocation:_currentLocation.lID];
            
            if (lastMenu != nil) {
                [self.beerMenu flagNewBeersSinceLastMenu: lastMenu];
            }
            
            if (self.currentServeType == nil){
                self.currentServeType = [self.beerMenu.serveTypeKeys objectAtIndex:0];
                [self performSelectorOnMainThread:@selector(setMenuButton) withObject:nil waitUntilDone:NO];
            }
            
            [self performSelectorOnMainThread:@selector(didFinishReceivingMenu) withObject:nil waitUntilDone:NO];
        } failedWithError:^(NSError *error) {
            [self performSelectorOnMainThread:@selector(showErrorRefresh) withObject:nil waitUntilDone:NO];
        }];
    } else {
        self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Please connect to the internet"];
        [self.refreshControl performSelector:@selector(endRefreshing) withObject:nil afterDelay:1.0];
    }
}

- (void)showErrorRefresh
{
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"There was an error refreshing the menu"];
    [self performSelector:@selector(didFinishReceivingMenu) withObject:nil afterDelay:1.0];
}

- (void)loadBeersIntoTableView:(NSDictionary *)beers
{
    _menuLoaded = YES;
    _menuIsLoading = NO;
    
    [self.refreshControl endRefreshing];
    
    [self.beerTableViewController setGroupName:_group];
    [self.beerTableViewController setBeers:beers];
    
    if (!_loadingPreviousMenu) {
        [self.spinnerView stopAnimatingWithSuccessMessage: @"Grabbed Menu Successfully!" withDelay: 0.5 hide:^(BOOL isComplete) {
            [self.beerTableViewController showTableViewWithAnimate:YES completion:^(BOOL isComplete) {
            }];
        }];
    } else {
        _loadingPreviousMenu = NO;
        
        [self.beerTableViewController showTableViewWithAnimate:NO completion:^(BOOL isComplete) {
        }];
        [self.menu setLocation:_currentLocation];
    }
}

- (void) setRefreshControlMenuText
{
    NSDateFormatter *inFormat = [[NSDateFormatter alloc] init];
    [inFormat setDateFormat:@"MMM dd h:mm a"];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat: @"Last Updated %@ - Pull to Refresh",  [inFormat stringFromDate:self.beerMenu.createdOn]]];
}

- (void) didFinishReceivingMenu
{
    [self setRefreshControlMenuText];
    [self createFilterMenu];
    [self loadBeersIntoTableView: [self.beerMenu getBeersGrouped:_group serveType:self.currentServeType sort:_sort]];
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
    [button addTarget:self action:@selector(navigationTitleWasTouched) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"On Tap" forState:UIControlStateNormal];
    [[button titleLabel] setFont:[UIFont fontWithName:@"RhinoRaja" size:28]];
    [container addSubview:button];
    
    
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.navigationItem.titleView = container;
}

- (void)createTableViewController
{
    self.beerTableViewController = [[NormBeerTableViewController alloc]initWithStyle:UITableViewStylePlain];
    [self addChildViewController:self.beerTableViewController];
    self.beerTableViewController.delegate = self;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh Beer List"];
    [self.refreshControl addTarget:self action:@selector(refreshMenu) forControlEvents:UIControlEventValueChanged];
    
    self.beerTableViewController.refreshControl = self.refreshControl;
    
    
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, 320, self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height - self.navigationController.navigationBar.frame.origin.y) style:UITableViewStylePlain];
    self.tableView.dataSource = self.beerTableViewController;
    self.tableView.hidden = YES;
    self.tableView.delegate = self.beerTableViewController;
    
    
    [self.beerTableViewController setTableView:self.tableView];
    [self.view addSubview:self.tableView];
    
    
    // Search Bar
    _beerSearchBar = [[NormSearchBar alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)];
    _beerSearchBar.placeholder = @"Search Beers";
    
    UIView *listButtonsView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 153, _beerSearchBar.searchBarTextField.frame.size.height)];
    
    NSString *selectedGroupItem = @"Style";
    
    if ([_group isEqualToString:@"none"]) {
        selectedGroupItem = @"None";
    } else if ([_group isEqualToString:@"breweryName"]) {
        selectedGroupItem = @"Brewery";
    }
    _groupMenu = [[NormDropDownMenu alloc] initWithSelectedItem:selectedGroupItem items:@[@"None", @"Brewery", @"Style"]];
    
    NSString *selectedSortItem = @"Name";
    if ([_sort isEqualToString:@"abv"]) {
        selectedSortItem = @"ABV";
    } else if ([_sort isEqualToString:@"price"]) {
        selectedSortItem = @"Price";
    }
    _sortMenu = [[NormDropDownMenu alloc] initWithSelectedItem:selectedSortItem items:@[@"ABV", @"Price", @"Name"]];
    
    [_groupMenu setDelegate:self];
    [_sortMenu setDelegate:self];
    _groupMenu.frame = CGRectMake(0, 0, 78, _beerSearchBar.searchBarTextField.frame.size.height);
    _sortMenu.frame = CGRectMake(83, 0, 70, _beerSearchBar.searchBarTextField.frame.size.height);
    [_groupMenu setMenuImage:[UIImage imageNamed:@"group-button"]];
    [_sortMenu setMenuImage:[UIImage imageNamed:@"sort-button"]];
    [_groupMenu setSlideUnderView:_beerSearchBar];
    [_sortMenu setSlideUnderView:_beerSearchBar];
    
    [listButtonsView addSubview:_groupMenu];
    [listButtonsView addSubview:_sortMenu];
    
    [_beerSearchBar setRightView:listButtonsView];
    
    self.tableView.tableHeaderView =  _beerSearchBar;
    
    _beerSearchDisplayController = [[NormSearchDisplayController alloc] initWithContentsController:self searchBar:_beerSearchBar];

    _beerSearchDisplayController.delegate = (id)self.beerTableViewController;
    _beerSearchDisplayController.searchResultsDataSource = self.beerTableViewController;
    _beerSearchDisplayController.searchResultsDelegate = self.beerTableViewController;
    
    
}

- (void)createSpinner
{
    self.spinnerView = [[NormIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    [self.spinnerView setCenter:CGPointMake(self.navigationController.view.frame.size.width / 2, self.navigationController.view.frame.size.height  / 2 - 44)];
    [self.spinnerView setHidesWhenStopped:YES];
    [self.view addSubview:self.spinnerView];
    [self.view bringSubviewToFront:self.spinnerView];
}

-(void)createMenu
{
    self.menu = [[NormServeTypeMenu alloc] init];
    self.menu.delegate = self;
}


- (void)createFilterMenu
{
    [self.menu setServeTypes:self.beerMenu.serveTypeKeys withBeerCounts:[self.beerMenu getBeerCountsForServeTypes]];
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

- (void)navigationTitleWasTouched
{
    [self toggleMenu];
}

- (void)toggleMenu
{
    if (self.menu.isOpen)
        return [self.menu close];
    
    [self.menu showFromNavigationController:self.navigationController];
}

-(void)didSelectItem:(NSString *)selectedItem dropDownMenu:(NormDropDownMenu *)dropDownMenu
{
    
    if (dropDownMenu == _sortMenu) {
        _sort = [selectedItem lowercaseString];
        _currentUser.sortPreference = _sort;
    } else if (dropDownMenu == _groupMenu) {
        if ([selectedItem isEqualToString:@"Style"]) {
            _group = @"styleCategory";
        } else if ([selectedItem isEqualToString:@"Brewery"]) {
            _group = @"breweryName";
        } else {
            _group = [selectedItem lowercaseString];
        }
        _currentUser.groupPreference = _group;
    }
    
    [_currentUser save];
    
    [self loadBeersIntoTableView: [self.beerMenu getBeersGrouped:_group serveType:self.currentServeType sort:_sort]];
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, self.tableView.tableHeaderView.frame.size.height) animated:NO];
}

@end
