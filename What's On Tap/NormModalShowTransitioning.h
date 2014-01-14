//
//  AnimatedTransitioning.h
//  CustomTransitionExample
//
//  Created by Blanche Faur on 10/24/13.
//  Copyright (c) 2013 Blanche Faur. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NormModalControllerDelegate.h"

@interface NormModalShowTransitioning : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) BOOL isPresenting;
@property (nonatomic, assign) UIViewController <NormModalControllerDelegate> *toVC;
@property (nonatomic, assign) UIViewController *fromVC;
@property (nonatomic, assign) UIView *animationView;
@property (nonatomic, assign) float duration;
@property (nonatomic, assign) float zoomOutPercentage;

- (id) initWithFromController:(UIViewController *)fromVC toController:(UIViewController *)toVC;
- (void) willAnimateShowTransition;
- (void) addShowAnimations;
- (void) didAnimateShowTransition;
- (void) willAnimateHideTransition;
- (void) addHideAnimations;
- (void) didAnimateHideTransition;
@end