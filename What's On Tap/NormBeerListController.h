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
#import "NormMenu.h"
#import "NormBeerViewController.h"
#import "NormBeerTableCell.h"

@interface NormBeerListController : UIViewController

@property NormMenu *beerMenu;
@property NSString *currentServeType;
@property NSString *filterString;

@property (nonatomic) UITableView *tableView;
@property (nonatomic) UIActivityIndicatorView *spinner;
@property UIRefreshControl *refreshControl;

@property UISearchBar *beerSearchBar;
@property UISearchDisplayController *beerSearchDisplayController;
@property NSMutableDictionary *beerSearchData;
@property (strong, readwrite, nonatomic) REMenu *menu;

@end
