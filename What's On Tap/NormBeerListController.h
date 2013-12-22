//
//  NormBeerListController.h
//  What's On Tap
//
//  Created by Ryan Norman on 11/28/13.
//  Copyright (c) 2013 Ryan Norman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "REMenu.h"

@interface NormBeerListController : UIViewController

- (void)loadBeersIntoTableView;
- (void)groupBeerStylesInServeType:(NSString *)serveType;
- (void)groupBeers:(NSString *)seachString containsStyle:(NSString *)style;
@property (nonatomic, weak) IBOutlet UITabBarItem *onTapItem;
@property (strong, readonly, nonatomic) REMenu *menu;

- (void)toggleMenu;
- (void)createFilterMenu;
- (void)filterBeerStyle:(NSString *)style;
@end
