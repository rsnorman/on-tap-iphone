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

#import "NormLocationFinderController.h"
#import "NormModalTransitionDelegate.h"
#import "NormLocationFinderDelegate.h"
#import "NormBeerTableViewControllerDelegate.h"
#import "NormConnectionManagerDelegate.h"
#import "NormStyleMenuDelegate.h"
#import "TestFlight.h"
#import <QuartzCore/QuartzCore.h>

@interface NormBeerListController () <NormLocationFinderDelegate, NormConnectionManagerDelegate, NormBeerTableViewControllerDelegate, NormServeTypeMenuDelegate>
@end

@implementation NormBeerListController

@synthesize managedObjectContext;

Location *_currentLocation;
User *_currentUser;
BOOL menuLoaded;
BOOL menuIsLoading;

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
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self createNavigationController];
    
    [self createTableViewController];
    
    [self createSpinner];
    
    [self createMenu];
    
    _currentUser = [User current];
    _currentLocation = _currentUser.currentLocation;
    menuLoaded = NO;
    
    self.connectionManager = [[NormConnectionManager alloc] init];
    [self.connectionManager setDelegate:self];
    [self.connectionManager performSelectorInBackground:@selector(checkForConnection) withObject:nil];
    [self performSelector:@selector(stillCheckingForNetworkConnection) withObject:nil afterDelay:1.0];
    
    // Load users last location
    if (_currentLocation == nil) {
        [self showSelectLocationFinder];
    } else {
        [self.spinnerView setMessage:[NSString stringWithFormat:@"Grabbing menu for\n%@", _currentLocation.name]];
    }
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void) stillCheckingForNetworkConnection
{
    if (self.connectionManager.isCheckingConnection) {
        
        [self.spinnerView setHidden:NO];
        
        // Load users last location
        if (_currentLocation != nil) {
            [self.menu setLocation:_currentLocation];
            [self.spinnerView setMessage:[NSString stringWithFormat:@"Grabbing menu for\n%@", _currentLocation.name]];
        }
    }
}

/*!
 * Called by Reachability whenever status changes.
 */
- (void) didConnectToNetwork
{
    if (_currentLocation != nil) {
        if (!menuLoaded) {
            [self.menu setLocation:_currentLocation];
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
    if (!menuLoaded) {
        [self performSelectorOnMainThread:@selector(showNoInternetConnection) withObject:nil waitUntilDone:NO];
    }
}

- (void)showNoInternetConnection
{
    [self.spinnerView stopAnimating];
    [self.spinnerView setMessage:@"Please connect to the Internet"];
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
        [self loadBeersIntoTableView: [self.beerMenu getBeersGroupedByStyleForServeType:self.currentServeType]];
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
        
        [self.menu setLocation:_currentLocation];
        
        if (_currentLocation != nil) {
            [self.beerTableViewController hideTableViewWithAnimate:YES completion:^(BOOL isComplete) {
                [self startFetchingAvailableMenu];
            }];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)startFetchingAvailableMenu
{
    if (menuIsLoading) {
        return;
    }
    
    menuLoaded = NO;
    
    if (_currentLocation == nil) {
        [self showErrorWithMessage:@"Select a location from the menu"];
        return;
    }
    
    self.beerMenu = [Menu getCurrentForLocation:_currentLocation.lID];
    
    if (self.beerMenu != nil) {
        if (self.currentServeType == nil){
            self.currentServeType = [self.beerMenu.serveTypeKeys objectAtIndex:0];
            [self performSelectorOnMainThread:@selector(setMenuButton) withObject:nil waitUntilDone:NO];
        }
        
        [self didFinishReceivingMenu];
    } else {
        
        if (!self.connectionManager.isConnectedToInternet) {
            [self showErrorWithMessage:@"Please connect to the Internet"];
            return;
        }
        
        // Fetch beers from server
        [self.spinnerView setMessage:[NSString stringWithFormat:@"Grabbing menu for\n%@", _currentLocation.name]];
        [self.spinnerView startAnimating];
        [self.spinnerView setHidden:NO];
        
        NSLog(@"Start fetching location");
        menuIsLoading = YES;
        [Menu fetchForLocation:_currentLocation.lID success: ^(Menu *beerMenu) {
            self.beerMenu = beerMenu;
            
            if (self.currentServeType == nil){
                self.currentServeType = [self.beerMenu.serveTypeKeys objectAtIndex:0];
                [self performSelectorOnMainThread:@selector(setMenuButton) withObject:nil waitUntilDone:NO];
            }
            
            [self performSelectorOnMainThread:@selector(didFinishReceivingMenu) withObject:nil waitUntilDone:NO];
        } failedWithError:^(NSError *error) {
            
            NSString *errorMessage = [NSString stringWithFormat: @"Sorry, there was a problem grabbing the menu for \n%@. \nKegs must be busted.", _currentLocation.name];
            [self performSelectorOnMainThread:@selector(showErrorWithMessage:) withObject: errorMessage waitUntilDone:NO];
            
            [TestFlight passCheckpoint:@"Error Grabbing Beer Menu"];
        }];
    }

}

- (void)showErrorWithMessage:(NSString *)errorMessage
{
    [self.spinnerView setMessage:errorMessage];
    [self.spinnerView stopAnimating];
    [self.spinnerView setHidden:NO];
}

- (void)refreshMenu
{
    if (self.connectionManager.isConnectedToInternet) {
        self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Updating Menu..."];
        
        // Fetch beers from server
        [Menu refreshForLocation:_currentLocation.lID success: ^(Menu *beerMenu) {
            self.beerMenu = beerMenu;
            
            if (self.currentServeType == nil){
                self.currentServeType = [self.beerMenu.serveTypeKeys objectAtIndex:0];
                [self performSelectorOnMainThread:@selector(setMenuButton) withObject:nil waitUntilDone:NO];
            }
            
            [self performSelectorOnMainThread:@selector(didFinishReceivingMenu) withObject:nil waitUntilDone:NO];
        } failedWithError:^(NSError *error) {
            [self performSelectorOnMainThread:@selector(showErrorRefresh) withObject:nil waitUntilDone:NO];
            [TestFlight passCheckpoint:@"Error Refreshing Menu"];
        }];
        
        [TestFlight passCheckpoint:@"Refreshed Menu"];
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
    menuLoaded = YES;
    menuIsLoading = NO;
    
    [self.spinnerView stopAnimating];
    [self.spinnerView setHidden:YES];
    [self.refreshControl endRefreshing];
    
    [self.beerTableViewController setBeers:beers];
    [self.beerTableViewController showTableViewWithAnimate:YES completion:^(BOOL isComplete) {
        
    }];
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
    [self loadBeersIntoTableView: [self.beerMenu getBeersGroupedByStyleForServeType:self.currentServeType]];
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
    _beerSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    _beerSearchBar.placeholder = @"Search Beers";
    self.tableView.tableHeaderView = _beerSearchBar;
    _beerSearchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:_beerSearchBar contentsController:self];
    _beerSearchDisplayController.delegate = (id)self.beerTableViewController;
    _beerSearchDisplayController.searchResultsDataSource = self.beerTableViewController;
    _beerSearchDisplayController.searchResultsDelegate = self.beerTableViewController;
}

- (void)createSpinner
{
    self.spinnerView = [[NormIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 200, 150)];
    self.spinnerView.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height  / 2 - 25);
    [self.spinnerView setHidesWhenStopped:YES];
    [self.view addSubview:self.spinnerView];
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
    [TestFlight passCheckpoint:@"Opened Menu From Navigation Title"];
    [self toggleMenu];
}

- (void)toggleMenu
{
    if (self.menu.isOpen)
        return [self.menu close];
    
    [self.menu showFromNavigationController:self.navigationController];
    
    [TestFlight passCheckpoint:@"Opened Menu"];
}

@end
