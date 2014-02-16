//
//  NormDrawerController.h
//  On Tap
//
//  Created by Ryan Norman on 2/15/14.
//  Copyright (c) 2014 Ryan Norman. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NormDrawerControllerDelegate <NSObject>

@optional
- (void) willCloseDrawer:(UIView *)drawer;
- (void) didCloseDrawer:(UIView *)drawer;;
- (void) willOpenDrawer:(UIView *)drawer;;
- (void) didOpenDrawer:(UIView *)drawer;;

@end

@interface NormDrawerController : UIViewController

@property (retain, nonatomic) UIViewController<NormDrawerControllerDelegate> *delegate;
@property (retain, nonatomic, readonly) UIView *drawerView;
@property (readonly) BOOL isOpen;

- (id) initWithDelegate:(id<NormDrawerControllerDelegate>)delegate;
- (void) setDrawerView:(UIView *)drawerView;
- (void) open;
- (void) close;

@end
