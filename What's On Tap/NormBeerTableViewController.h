//
//  NormBeerTableViewController.h
//  On Tap
//
//  Created by Ryan Norman on 2/9/14.
//  Copyright (c) 2014 Ryan Norman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NormBeerTableViewControllerDelegate.h"

@interface NormBeerTableViewController : UITableViewController

@property NSArray *currentBeerStyles;
@property NSDictionary *currentBeersGroupedByStyle;
@property UISearchBar *beerSearchBar;

@property id<NormBeerTableViewControllerDelegate> delegate;

- (void)setBeers:(NSDictionary *)beers;
- (void) showTableViewWithAnimate:(BOOL)animated completion:(void (^)(BOOL isComplete))completionAction;
- (void) hideTableViewWithAnimate:(BOOL)animated completion:(void (^)(BOOL isComplete))completionAction;

@end
