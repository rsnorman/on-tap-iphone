//
//  NormSearchDisplayController.h
//  On Tap
//
//  Created by Ryan Norman on 2/22/14.
//  Copyright (c) 2014 Ryan Norman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NormSearchBar.h"

@class NormSearchDisplayController;

@protocol NormSearchDisplayDelegate <NSObject>

@optional

- (BOOL)searchDisplayController:(NormSearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString;
- (void)searchDisplayControllerDidBeginSearch:(NormSearchDisplayController *)controller;
- (void)searchDisplayControllerWillEndSearch:(NormSearchDisplayController *)controller;

@end

@interface NormSearchDisplayController : UIViewController

@property (nonatomic, retain, readonly) NormSearchBar *searchBar;
@property (nonatomic, retain, readonly) UIViewController *contentsController;
@property id<NormSearchDisplayDelegate> delegate;
@property id<UITableViewDataSource> searchResultsDataSource;
@property id<UITableViewDelegate> searchResultsDelegate;

- (id) initWithContentsController: (UIViewController *)contentsController searchBar: (NormSearchBar *)searchBar;

@end