//
//  TransitionDelegate.m
//  CustomTransitionExample
//
//  Created by Blanche Faur on 10/24/13.
//  Copyright (c) 2013 Blanche Faur. All rights reserved.
//

#import "NormTransitionDelegate.h"
#import "NormImageShowTransitioning.h"
#import "NormImageHideTransitioning.h"


@implementation NormTransitionDelegate

//===================================================================
// - UIViewControllerTransitioningDelegate
//===================================================================

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    
    NormImageShowTransitioning *controller = [[NormImageShowTransitioning alloc] init];
    
    [controller setFromVC:presenting];
    [controller setToVC:presented];
    controller.isPresenting = YES;
    
    return controller;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    NormImageHideTransitioning *controller = [[NormImageHideTransitioning alloc] init];
    
    [controller setFromVC:dismissed];
    [controller setToVC:[dismissed presentingViewController]];
    controller.isPresenting = NO;
    
    return controller;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator {
    return nil;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator {
    return nil;
}

@end