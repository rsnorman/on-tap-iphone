//
//  AnimatedTransitioning.m
//  CustomTransitionExample
//
//  Created by Blanche Faur on 10/24/13.
//  Copyright (c) 2013 Blanche Faur. All rights reserved.
//

#import "NormModalHideTransitioning.h"
#import "NormViewSnapshot.h"

@implementation NormModalHideTransitioning

//===================================================================
// - UIViewControllerAnimatedTransitioning
//===================================================================


- (id) initWithFromController:(UIViewController *)fromVC toController:(UIViewController *)toVC
{
    self = [super init];
    if (self) {
        [self setToVC:toVC];
        [self setFromVC:fromVC];
        self.duration = 0.25f;
        self.zoomOutPercentage = 0.95;
    }
    
    return self;
}

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return self.duration;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    
    float zoomOutPaddingX = (self.bgImage.size.width - (self.bgImage.size.width * self.zoomOutPercentage)) / 2;
    float zoomOutPaddingY = (self.bgImage.size.height - (self.bgImage.size.height * self.zoomOutPercentage)) / 2;
    
    UIImageView *bgImageView = [[UIImageView alloc] initWithImage:self.bgImage];
    UIImageView *bgBlurredImageView = [[UIImageView alloc] initWithImage:self.blurredBgImage];
    
    bgImageView.frame = CGRectMake(zoomOutPaddingX, zoomOutPaddingY, self.bgImage.size.width - (zoomOutPaddingX * 2), self.bgImage.size.height - (zoomOutPaddingY * 2));
    
    bgBlurredImageView.frame = CGRectMake(zoomOutPaddingX, zoomOutPaddingY, self.bgImage.size.width - (zoomOutPaddingX * 2), self.bgImage.size.height - (zoomOutPaddingY * 2));
    
    UIView *borderView = [[UIView alloc] initWithFrame:self.toVC.view.frame];
    [borderView setBackgroundColor:[UIColor blackColor]];
    [borderView addSubview:bgImageView];
    [borderView addSubview:bgBlurredImageView];
    
    
    UIView *inView = [transitionContext containerView];
    [inView addSubview:borderView];
    
    [UIView animateWithDuration:self.duration
                     animations:^{
                         bgBlurredImageView.alpha = 0.0f;
                         [borderView setFrame:CGRectMake(zoomOutPaddingX * -1, zoomOutPaddingY * -1, inView.window.frame.size.width + (zoomOutPaddingX * 2), inView.window.frame.size.height + zoomOutPaddingY * 2)];
                         [bgImageView setFrame:CGRectOffset(self.toVC.view.frame, zoomOutPaddingX, zoomOutPaddingY)];
                         [bgBlurredImageView setFrame:CGRectOffset(self.toVC.view.frame, zoomOutPaddingX, zoomOutPaddingY)];
                         
                     }
                     completion:^(BOOL finished) {
                         [transitionContext completeTransition:YES];
                     }];
}


- (void) animationEnded:(BOOL)transitionCompleted {
    
}


@end