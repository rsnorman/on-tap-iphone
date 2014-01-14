//
//  TransitionDelegate.m
//  CustomTransitionExample
//
//  Created by Blanche Faur on 10/24/13.
//  Copyright (c) 2013 Blanche Faur. All rights reserved.
//

#import "NormImageModalTransitionDelegate.h"
#import "NormImageShowTransitioning.h"
#import "NormModalControllerDelegate.h"


@implementation NormImageModalTransitionDelegate

NormImageShowTransitioning *controller;

//===================================================================
// - UIViewControllerTransitioningDelegate
//===================================================================

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(NormImageModalController <NormModalControllerDelegate> *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
        
    controller = [[NormImageShowTransitioning alloc] init];
    
    [controller setFromVC:presenting];
    [controller setToVC:presented];
    [controller setDuration:self.duration];
    [controller setZoomOutPercentage: self.zoomOutPercentage];
    controller.isPresenting = YES;
    
    [controller setPresentingImage:self.transitionImage];
    [controller setPresentingImageStartFrame:self.startFrame];
    [controller setPresentingImageFinishFrame:self.finishFrame];
    [controller setPresentingImageStartLayer:self.startLayer];
    [controller setPresentingImageFinishLayer:self.finishLayer];

    return controller;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    
    controller.isPresenting = NO;
    
    return controller;
}

@end