//
//  NormDropDownMenu.h
//  On Tap
//
//  Created by Ryan Norman on 3/2/14.
//  Copyright (c) 2014 Ryan Norman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NormDropDownMenuController.h"

@class NormDropDownMenu;

@protocol NormDropDownMenuDelegate <NSObject>

- (void) didSelectItem: (NSString *) selectedItem dropDownMenu:(NormDropDownMenu *)dropDownMenu;

@end

@interface NormDropDownMenu : UIView
- (id) initWithSelectedItem:(NSString *) selectedItem items:(NSArray *)items;
- (void) setSelectedItem:(NSString *)selectedItem;

@property (nonatomic, retain, readonly) NSString *selectedItem;
@property (nonatomic, retain, readonly) NSArray *items;
@property (nonatomic, retain) UIView *slideUnderView;
@property id<NormDropDownMenuDelegate> delegate;
@end
