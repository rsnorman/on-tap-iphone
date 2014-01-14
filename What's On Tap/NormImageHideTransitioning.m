//
//  AnimatedTransitioning.m
//  CustomTransitionExample
//
//  Created by Blanche Faur on 10/24/13.
//  Copyright (c) 2013 Blanche Faur. All rights reserved.
//

#import "NormImageHideTransitioning.h"
#import "NormViewSnapshot.h"

@implementation NormImageHideTransitioning

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
    
    UIImageView *bgImageView = [[UIImageView alloc] initWithImage:self.bgImage];
    
    UIImageView *bgBlurredImageView = [[UIImageView alloc] initWithImage:self.blurredBgImage];
    
    float zoomOutPaddingX = (self.bgImage.size.width - (self.bgImage.size.width * self.zoomOutPercentage)) / 2;
    float zoomOutPaddingY = (self.bgImage.size.height - (self.bgImage.size.height * self.zoomOutPercentage)) / 2;
    
    bgImageView.frame = CGRectMake(zoomOutPaddingX, zoomOutPaddingY, self.bgImage.size.width - (zoomOutPaddingX * 2), self.bgImage.size.height - (zoomOutPaddingY * 2));
    
    bgBlurredImageView.frame = CGRectMake(zoomOutPaddingX, zoomOutPaddingY, self.bgImage.size.width - (zoomOutPaddingX * 2), self.bgImage.size.height - (zoomOutPaddingY * 2));
    
    UIView *borderView = [[UIView alloc] initWithFrame:self.toVC.view.frame];
    [borderView setBackgroundColor:[UIColor blackColor]];
    
    UIView *inView = [transitionContext containerView];
    
    [borderView addSubview:bgImageView];
    [borderView addSubview:bgBlurredImageView];
    [inView addSubview:borderView];

    UIImageView *animatedPresentingImageView = [[UIImageView alloc] initWithFrame:self.dismissingImageStartFrame];
    
    animatedPresentingImageView.layer.cornerRadius = self.dismissingImageStartLayer.cornerRadius;
    animatedPresentingImageView.layer.masksToBounds = self.dismissingImageStartLayer.masksToBounds;
    
    [animatedPresentingImageView setImage:self.dismissingImage];
    
    
    [inView addSubview:animatedPresentingImageView];
    
    
    [UIView animateWithDuration:self.duration
                     animations:^{
                         bgBlurredImageView.alpha = 0.0f;
                         [borderView setFrame:CGRectMake(zoomOutPaddingX * -1, zoomOutPaddingY * -1, inView.window.frame.size.width + (zoomOutPaddingX * 2), inView.window.frame.size.height + zoomOutPaddingY * 2)];
                         [bgImageView setFrame:CGRectOffset(self.toVC.view.frame, zoomOutPaddingX, zoomOutPaddingY)];
                         [bgBlurredImageView setFrame:CGRectOffset(self.toVC.view.frame, zoomOutPaddingX, zoomOutPaddingY)];
                         
                         animatedPresentingImageView.frame = self.dismissingImageFinishFrame;
                         
                         // Change the position explicitly.
                         CABasicAnimation* cornerRadiusAnim = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
                         cornerRadiusAnim.fromValue = [NSNumber numberWithFloat:self.dismissingImageStartLayer.cornerRadius];
                         cornerRadiusAnim.toValue = [NSNumber numberWithFloat:self.dismissingImageFinishLayer.cornerRadius];
                         cornerRadiusAnim.duration = self.duration;
                         
                         CABasicAnimation* borderWidthAnim = [CABasicAnimation animationWithKeyPath:@"borderWidth"];
                         borderWidthAnim.fromValue = [NSNumber numberWithFloat:self.dismissingImageStartLayer.borderWidth];
                         borderWidthAnim.toValue = [NSNumber numberWithFloat:self.dismissingImageFinishLayer.borderWidth];
                         borderWidthAnim.duration = self.duration;
                         
                         CABasicAnimation* borderColorAnim = [CABasicAnimation animationWithKeyPath:@"borderColor"];
                         borderColorAnim.fromValue = (id) self.dismissingImageStartLayer.borderColor;
                         borderColorAnim.toValue = (id) self.dismissingImageFinishLayer.borderColor;
                         borderColorAnim.duration = self.duration;
                         
                         animatedPresentingImageView.layer.cornerRadius = self.dismissingImageFinishLayer.cornerRadius;
                         animatedPresentingImageView.layer.borderWidth = self.dismissingImageFinishLayer.borderWidth;
                         animatedPresentingImageView.layer.borderColor = self.dismissingImageFinishLayer.borderColor;
                         animatedPresentingImageView.layer.masksToBounds = self.dismissingImageFinishLayer.masksToBounds;
                         
                         CAAnimationGroup *group = [CAAnimationGroup animation];
                         group.fillMode = kCAFillModeForwards;
                         group.removedOnCompletion = NO;
                         group.duration = self.duration;
                         [group setAnimations:@[cornerRadiusAnim, borderWidthAnim, borderColorAnim]];
                         group.delegate = self;
                         
                         
                         [animatedPresentingImageView.layer addAnimation:group forKey:@"AnimateFrame"];
                         
                     }
                     completion:^(BOOL finished) {
                         [transitionContext completeTransition:YES];
                     }];
}


- (void) animationEnded:(BOOL)transitionCompleted {
    
}


@end