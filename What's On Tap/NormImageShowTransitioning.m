//
//  AnimatedTransitioning.m
//  CustomTransitionExample
//
//  Created by Blanche Faur on 10/24/13.
//  Copyright (c) 2013 Blanche Faur. All rights reserved.
//

#import "NormImageShowTransitioning.h"
#import "NormBlurImage.h"

@implementation NormImageShowTransitioning

//===================================================================
// - UIViewControllerAnimatedTransitioning
//===================================================================


- (id) initWithFromController:(UIViewController *)fromVC toController:(UIViewController *)toVC
{
    self = [super init];
    if (self) {
        [self setToVC:toVC];
        [self setFromVC:fromVC];
    }
    
    return self;
}

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.25f;
}

-(UIImage *)blurredSnapshotOfView:(UIView *)view
{
    // Create the image context
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, view.window.screen.scale);
    
    // There he is! The new API method
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:NO];
    
    // Get the snapshot
    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // Now apply the blur effect using Apple's UIImageEffect category
//    UIImage *blurredSnapshotImage = [snapshotImage applyLightEffect];
    
    // Or apply any other effects available in "UIImage+ImageEffects.h"
    UIImage *blurredSnapshotImage = [snapshotImage applyDarkEffect];
    // UIImage *blurredSnapshotImage = [snapshotImage applyExtraLightEffect];
    
    // Be nice and clean your mess up
    UIGraphicsEndImageContext();
    
    return blurredSnapshotImage;
}

-(UIImage *)snapshotOfView:(UIView *)view
{
    // Create the image context
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, view.window.screen.scale);
    
    // There he is! The new API method
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:NO];
    
    // Get the snapshot
    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // Be nice and clean your mess up
    UIGraphicsEndImageContext();
    
    return snapshotImage;
}



- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    
    UIImage *bgImage = [self snapshotOfView:self.fromVC.view];
    UIImageView *bgImageView = [[UIImageView alloc] initWithImage:bgImage];
    
//    UIImage *bgBlurredImage = [self blurredSnapshotOfView:self.fromVC.view];
//    UIImageView *modalBlurredImageView = [[UIImageView alloc] initWithImage:bgBlurredImage];
    
    [bgImageView setFrame:CGRectMake(0, 0, bgImage.size.width, bgImage.size.height)];
//    [bgImageView setFrame:CGRectMake(0, 0, bgBlurredImage.size.width, bgBlurredImage.size.height)];
    
    UIView *inView = [transitionContext containerView];
    
    [inView addSubview:self.toVC.view];
    [inView addSubview:bgImageView];
    
    
//    [self.toVC.view addSubview:modalBlurredImageView];
//    [self.toVC.view sendSubviewToBack:modalBlurredImageView];



    [UIView animateWithDuration:0.25f
                     animations:^{
                         bgImageView.alpha = 0.0f;
                     }
                     completion:^(BOOL finished) {
                         [transitionContext completeTransition:YES];
                     }];
}

- (void) animationEnded:(BOOL)transitionCompleted {
    
}


@end