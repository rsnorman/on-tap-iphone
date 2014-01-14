//
//  TransitionDelegate.m
//  CustomTransitionExample
//
//  Created by Blanche Faur on 10/24/13.
//  Copyright (c) 2013 Blanche Faur. All rights reserved.
//

#import "NormModalTransitionDelegate.h"
#import "NormModalShowTransitioning.h"
#import "NormModalControllerDelegate.h"

@implementation NormModalTransitionDelegate

NormModalShowTransitioning *controller;

//===================================================================
// - UIViewControllerTransitioningDelegate
//===================================================================

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController <NormModalControllerDelegate> *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    
    controller = [[NormModalShowTransitioning alloc] init];
    
    [controller setFromVC:presenting];
    [controller setToVC:presented];
    [controller setDuration:self.duration];
    [controller setZoomOutPercentage: self.zoomOutPercentage];

    controller.isPresenting = YES;
    
    return controller;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    controller.isPresenting = NO;
    
    return controller;
}

@end