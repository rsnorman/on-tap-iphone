//
//  NormDrawerController.m
//  On Tap
//
//  Created by Ryan Norman on 2/15/14.
//  Copyright (c) 2014 Ryan Norman. All rights reserved.
//

#import "NormDrawerController.h"

@implementation NormDrawerController


- (id)initWithDelegate:(UIViewController<NormDrawerControllerDelegate> *)delegate
{
    self = [super init];
    
    if (self) {
        _delegate = delegate;
        self.view.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, 0, 0);
        [self.view setBackgroundColor:[UIColor whiteColor]];
        [self.view.layer setShadowColor:[UIColor darkGrayColor].CGColor];
        [self.view.layer setShadowRadius:3.0];
        [self.view.layer setShadowOpacity:0.9];
        [self.view.layer setOpacity:0.95];
        
        UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedDrawerDown:)];
        swipe.direction = UISwipeGestureRecognizerDirectionDown;
        [self.view addGestureRecognizer:swipe];
        
        [delegate.view addSubview:self.view];
    }
    
    return self;
}

- (void) swipedDrawerDown:(UIGestureRecognizer*)gesture
{
    [self close];
}

- (void) setDrawerView:(UIView *)drawerView
{
    _drawerView = drawerView;
    [self.view addSubview:_drawerView];
}

- (void) open
{
    if (_isOpen) {
        return;
    }
    
    [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.drawerView.frame.size.width, self.drawerView.frame.size.height)];
    
    NSLog(@"%f, %f, %f, %f", self.view.frame.size.width, self.view.frame.size.height, self.view.frame.origin.x, self.view.frame.origin.y);
    
    if ([_delegate respondsToSelector:@selector(willOpenDrawer:)]) {
        [_delegate willOpenDrawer:self.drawerView];
    }
    
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.view.frame = CGRectOffset(self.view.frame, 0, self.view.frame.size.height * -1);
                     }                   completion:^(BOOL finished) {
                         if ([_delegate respondsToSelector:@selector(didOpenDrawer:)]) {
                             [_delegate didOpenDrawer:self.drawerView];
                         }
                         
                         _isOpen = YES;
                     }
     ];
}

- (void) close
{
    if (!_isOpen) {
        return;
    }
    
    if ([_delegate respondsToSelector:@selector(willCloseDrawer:)]) {
        [_delegate willCloseDrawer:self.drawerView];
    }
    
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.view.frame = CGRectOffset(self.view.frame, 0, self.view.frame.size.height);
                     }                   completion:^(BOOL finished) {
                         if ([_delegate respondsToSelector:@selector(didCloseDrawer:)]) {
                             [_delegate didCloseDrawer:self.drawerView];
                         }
                         
                         _isOpen = NO;
                     }
     ];
}

@end
