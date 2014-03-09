//
//  NormSearchBar.h
//  On Tap
//
//  Created by Ryan Norman on 2/22/14.
//  Copyright (c) 2014 Ryan Norman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NormDropDownMenu.h"

@class NormSearchBar;

@protocol NormSearchBarDelegate <NSObject>

- (void)searchBarTextDidBeginEditing:(NormSearchBar *)searchBar;
- (void)searchBarCancelButtonClicked:(NormSearchBar *)searchBar;
- (void)searchBar:(NormSearchBar *)searchBar textDidChange:(NSString *)searchText;

@end

@interface NormSearchBar : UIView

@property id<NormSearchBarDelegate> delegate;
@property UITextField *searchBarTextField;

- (void) setText:(NSString *)text;
- (void) setShowsCancelButton:(BOOL)showsCancelButton animated:(BOOL)animated;
- (void) setPlaceholder:(NSString *)placeholder;
- (void) setRightView:(UIView *) rightView;
@end
