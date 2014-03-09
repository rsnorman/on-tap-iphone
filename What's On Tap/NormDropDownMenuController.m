//
//  NormDropDownMenuController.m
//  On Tap
//
//  Created by Ryan Norman on 3/6/14.
//  Copyright (c) 2014 Ryan Norman. All rights reserved.
//

#import "NormDropDownMenuController.h"
#import "NormViewSnapshot.h"
#import "NormDropDownMenu.h"

@interface NormDropDownMenuController ()
@property NormDropDownMenu *dropDownMenu;
@property NSMutableArray *itemButtons;
@property CGRect menuParentFrame;
@end

@implementation NormDropDownMenuController

- (id)initWithDropDownMenu:(NormDropDownMenu *)dropDownMenu
{
    self = [super init];
    if (self) {
        self.dropDownMenu = dropDownMenu;
        self.itemButtons = [[NSMutableArray alloc] init];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	
    
    UIImage *bgImage = [NormViewSnapshot snapshotOfWindow:((UIViewController *)self.dropDownMenu.delegate).view];
    UIImageView *bgImageView = [[UIImageView alloc] initWithImage:bgImage];
    
    UITapGestureRecognizer *dismissMenuTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissMenu)];
    dismissMenuTap.numberOfTapsRequired = 1;
    
    [bgImageView addGestureRecognizer:dismissMenuTap];
    [bgImageView setUserInteractionEnabled:YES];
    [self.view addSubview:bgImageView];
    
    _menuParentFrame = [self.dropDownMenu.slideUnderView convertRect:self.dropDownMenu.slideUnderView.bounds toView:nil];
    CGRect ddFrame = [self.dropDownMenu convertRect:self.dropDownMenu.bounds toView:nil];;
    
    
    for (NSString *item in self.dropDownMenu.items) {
        UIButton *itemButton = [[UIButton alloc] initWithFrame:CGRectMake(ddFrame.origin.x, ddFrame.origin.y, ddFrame.size.width, ddFrame.size.height)];
        [itemButton setTitle:item forState:UIControlStateNormal];
        [itemButton addTarget:self action:@selector(selectMenuItem:) forControlEvents:UIControlEventTouchUpInside];
        [itemButton.layer setOpacity:0.0];
        [itemButton.layer setBackgroundColor:[UIColor blackColor].CGColor];
        [itemButton.layer setCornerRadius:8.0];
        [itemButton.titleLabel setFont:[UIFont systemFontOfSize:18.0]];
        [itemButton sizeToFit];
        itemButton.frame = CGRectMake(itemButton.frame.origin.x, itemButton.frame.origin.y, itemButton.frame.size.width + 30, itemButton.frame.size.height + 10);
        [self.view addSubview:itemButton];
        
        if (true /*Align to right*/) {
            itemButton.frame = CGRectOffset(itemButton.frame, self.dropDownMenu.frame.size.width - itemButton.frame.size.width, 0);
        }
        
        [_itemButtons addObject:itemButton];
    }
    
    UIImage *parentViewImage = [NormViewSnapshot snapshotOfView:self.dropDownMenu.slideUnderView];
    UIImageView *parentViewImageView = [[UIImageView alloc] initWithImage:parentViewImage];
    parentViewImageView.frame = _menuParentFrame;
    [self.view addSubview:parentViewImageView];
    [self.view bringSubviewToFront:parentViewImageView];
    
    float delay = 0.0;
    float duration = 0.4;
    float topMargin = (((UIButton *)[_itemButtons objectAtIndex:0]).frame.size.height + 10.0) * _itemButtons.count;

    
    topMargin += _menuParentFrame.size.height;
    
    for (UIButton *itemButton in _itemButtons) {
        topMargin -= itemButton.frame.size.height + 10.0;
        
        [itemButton.layer setOpacity:0.0];
        
        [UIView animateWithDuration:duration
                              delay:delay
             usingSpringWithDamping:0.4
              initialSpringVelocity:1.0
                            options:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             itemButton.frame = CGRectOffset(itemButton.frame, 0, topMargin);
                             [itemButton.layer setOpacity:0.8];
                         }
                         completion:^(BOOL finished) {
                             
                         }];
        
        delay += 0.05;
        
        
    }
    
}

- (void)selectMenuItem:(UIButton *)menuButton
{
    [self.dropDownMenu setSelectedItem:menuButton.titleLabel.text];
    [self.dropDownMenu.delegate didSelectItem:menuButton.titleLabel.text dropDownMenu:self.dropDownMenu];
    [self dismissMenu];
}

- (void)dismissMenu
{
        [UIView animateWithDuration:0.1
                              delay:0.0
                            options:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             for (UIButton *itemButton in _itemButtons) {
                                 [itemButton.layer setOpacity:0.0];
                                 itemButton.frame = CGRectMake(itemButton.frame.origin.x, _menuParentFrame.origin.y, itemButton.frame.size.width, itemButton.frame.size.height);
                             }
                         }
                         completion:^(BOOL finished) {
                             [self dismissViewControllerAnimated:NO completion:nil];
                         }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
