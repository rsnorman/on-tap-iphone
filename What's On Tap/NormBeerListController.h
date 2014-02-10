//
//  NormBeerListController.h
//  What's On Tap
//
//  Created by Ryan Norman on 11/28/13.
//  Copyright (c) 2013 Ryan Norman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "REMenu.h"
#import "Menu.h"
#import "NormBeerViewController.h"
#import "NormBeerTableCell.h"
#import "NormIndicatorView.h"
#import "constants.h"
#import "NormConnectionManager.h"

// Controller for view the list of all beers on a menu
@interface NormBeerListController : UIViewController

// Menu that contains all the beers
@property Menu *beerMenu;

// Current serve type that is being displayed
@property NSString *currentServeType;

@property NSArray *currentBeerStyles;
@property NSDictionary *currentBeersGroupedByStyle;

// Table view that has the menu beers as a data source
@property (nonatomic) UITableView *tableView;

// Spinner to indicate menu is being loaded
@property (nonatomic) NormIndicatorView *spinnerView;

// Refresh control to allow pull down action to refresh menu
@property UIRefreshControl *refreshControl;

// Search bar for filtering beers
@property UISearchBar *beerSearchBar;

// Search display controller for filtering beers
@property UISearchDisplayController *beerSearchDisplayController;

@property UILabel *errorLabel;

// Drop down menu for selecting different serve types from the menu
@property (strong, readwrite, nonatomic) REMenu *menu;

// Managed context for saving menu and beers
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (nonatomic) NormConnectionManager *connectionManager;

@end
