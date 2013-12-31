//
//  NormBeerListController.h
//  What's On Tap
//
//  Created by Ryan Norman on 11/28/13.
//  Copyright (c) 2013 Ryan Norman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "REMenu.h"
#import "NormBeer.h"
#import "NormBeerViewController.h"
#import "NormBeerTableCell.h"
#import "NormMenuManager.h"
#import "NormWhatsOnTap.h"

@interface NormBeerListController : UIViewController

@property NSArray *allBeers;

@property NSString *currentServeType;
@property NSMutableDictionary *serveTypes;
@property NSMutableArray *serveTypeKeys;
@property NSMutableDictionary *styles;
@property NSArray *styleKeys;
@property NormMenuManager *menuManager;

@property (nonatomic) UITableView *tableView;
@property (nonatomic) UIActivityIndicatorView *spinner;
@property UIRefreshControl *refreshControl;

@property UISearchBar *beerSearchBar;
@property UISearchDisplayController *beerSearchDisplayController;
@property NSMutableDictionary *beerSearchData;
@property (strong, readwrite, nonatomic) REMenu *menu;

@end
