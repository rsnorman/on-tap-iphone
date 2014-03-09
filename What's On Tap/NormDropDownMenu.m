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
@property UILabel *selectedItemButton;
@end

@implementation NormDropDownMenu

- (id)initWithSelectedItem: (NSString *)selectedItem items:(NSArray *)items
{
    self = [super init];
    if (self) {
        _selectedItem = selectedItem;
        _items = items;
        
        _selectedItemButton = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 44)];
//        [_selectedItemButton setTitle:selectedItem forState:UIControlStateNormal];
        [_selectedItemButton setText:selectedItem];
//        [_selectedItemButton addTarget:self action:@selector(showMenuItems) forControlEvents:UIControlEventTouchUpInside];
        [_selectedItemButton setFont:[UIFont systemFontOfSize:13.0]];
        [_selectedItemButton setTextAlignment:NSTextAlignmentLeft];
//        [_selectedItemButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_selectedItemButton setTextColor:[UIColor whiteColor]];
        [_selectedItemButton sizeToFit];
//        [_selectedItemButton setTintColor:[UIColor whiteColor]];
//        [_selectedItemButton.layer setBorderColor:[UIColor whiteColor].CGColor];
//        [_selectedItemButton.layer setBorderWidth:1.0];
        [self.layer setBorderColor:[UIColor lightGrayColor].CGColor];
        [self.layer setBorderWidth:1.0];
        [self.layer setCornerRadius:4.0];
        [self setBackgroundColor:[UIColor lightGrayColor]];
        
        self.frame = _selectedItemButton.frame;
        [self addSubview:_selectedItemButton];
        
        UITapGestureRecognizer *menuTapped = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showMenuItems)];
        menuTapped.numberOfTapsRequired = 1;
        [self addGestureRecognizer:menuTapped];
        
    }
    return self;
}

- (void)setSelectedItem:(NSString *)selectedItem
{
//    [_selectedItemButton setTitle:selectedItem forState:UIControlStateNormal];
    [_selectedItemButton setText: selectedItem];
    [_selectedItemButton sizeToFit];
    _selectedItemButton.frame = CGRectMake(_selectedItemButton.frame.origin.x, _selectedItemButton.frame.origin.y, _selectedItemButton.frame.size.width, self.frame.size.height);
    _selectedItem = selectedItem;
}

- (void)setMenuImage:(UIImage *)buttonImage
{
    UIImageView *buttonImageView = [[UIImageView alloc] initWithFrame:CGRectMake(3, 5, 17, 17)];
    [buttonImageView setImage:buttonImage];
    [buttonImageView setTintColor:[UIColor whiteColor]];
    [self addSubview:buttonImageView];
//    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width + 18, self.frame.size.height);
    self.selectedItemButton.frame = CGRectOffset(self.selectedItemButton.frame, 25, 0);
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    _selectedItemButton.frame = CGRectMake(0, 0, _selectedItemButton.frame.size.width, frame.size.height);
}

- (void)showMenuItems
{
    
    [((UIViewController *)_delegate) presentViewController:[[NormDropDownMenuController alloc] initWithDropDownMenu: self] animated:NO completion:nil];
}

@end
