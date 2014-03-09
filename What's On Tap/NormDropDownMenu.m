//
//  NormDropDownMenu.m
//  On Tap
//
//  Created by Ryan Norman on 3/2/14.
//  Copyright (c) 2014 Ryan Norman. All rights reserved.
//

#import "NormDropDownMenu.h"
#import "NormViewSnapshot.h"
#import "constants.h"

@interface NormDropDownMenu ()
@property UIButton *selectedItemButton;
@end

@implementation NormDropDownMenu

- (id)initWithSelectedItem: (NSString *)selectedItem items:(NSArray *)items
{
    self = [super init];
    if (self) {
        _selectedItem = selectedItem;
        _items = items;
        
        _selectedItemButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 55, 44)];
        [_selectedItemButton setTitle:selectedItem forState:UIControlStateNormal];
        [_selectedItemButton addTarget:self action:@selector(showMenuItems) forControlEvents:UIControlEventTouchUpInside];
        [_selectedItemButton.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
        [_selectedItemButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_selectedItemButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_selectedItemButton sizeToFit];
        [_selectedItemButton.layer setBorderColor:[UIColor lightGrayColor].CGColor];
        [_selectedItemButton.layer setBorderWidth:1.0];
        [_selectedItemButton.layer setCornerRadius:4.0];
        [_selectedItemButton setBackgroundColor:[UIColor lightGrayColor]];
        
        self.frame = _selectedItemButton.frame;
        [self addSubview:_selectedItemButton];
        
    }
    return self;
}

- (void)setSelectedItem:(NSString *)selectedItem
{
    [_selectedItemButton setTitle:selectedItem forState:UIControlStateNormal];
    _selectedItem = selectedItem;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    _selectedItemButton.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
}

- (void)showMenuItems
{
    
    [((UIViewController *)_delegate) presentViewController:[[NormDropDownMenuController alloc] initWithDropDownMenu: self] animated:NO completion:nil];
}

@end
