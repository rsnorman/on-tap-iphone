//
//  AnimatedTransitioning.m
//  CustomTransitionExample
//
//  Created by Blanche Faur on 10/24/13.
//  Copyright (c) 2013 Blanche Faur. All rights reserved.
//

#import "NormImageShowTransitioning.h"
#import "constants.h"

@implementation NormImageShowTransitioning

UIImageView *animatedPresentingImageView;

- (void) willAnimateShowTransition
{
    [super willAnimateShowTransition];
    
    animatedPresentingImageView = [[UIImageView alloc] initWithFrame:self.presentingImageStartFrame];
    [animatedPresentingImageView setBackgroundColor:[UIColor whiteColor]];
    
    animatedPresentingImageView.layer.cornerRadius = self.presentingImageStartLayer.cornerRadius;
    animatedPresentingImageView.layer.masksToBounds = self.presentingImageStartLayer.masksToBounds;
    
    [animatedPresentingImageView setImage:self.presentingImage];
    
    if (self.presentingImage.size.height / self.presentingImage.size.width > _MAX_IMAGE_RATIO) {
        [animatedPresentingImageView setContentMode:UIViewContentModeScaleAspectFit];
    } else{
        [animatedPresentingImageView setContentMode:UIViewContentModeScaleToFill];
    }
    
    [self.animationView addSubview:animatedPresentingImageView];
}

- (void) addShowAnimations
{
    [super addShowAnimations];
    
    animatedPresentingImageView.frame = self.presentingImageFinishFrame;
    
    // Change the position explicitly.
    CABasicAnimation* cornerRadiusAnim = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
    cornerRadiusAnim.fromValue = [NSNumber numberWithFloat:self.presentingImageStartLayer.cornerRadius];
    cornerRadiusAnim.toValue = [NSNumber numberWithFloat:self.presentingImageFinishLayer.cornerRadius];
    cornerRadiusAnim.duration = self.duration;
    
    CABasicAnimation* borderWidthAnim = [CABasicAnimation animationWithKeyPath:@"borderWidth"];
    borderWidthAnim.fromValue = [NSNumber numberWithFloat:self.presentingImageStartLayer.borderWidth];
    borderWidthAnim.toValue = [NSNumber numberWithFloat:self.presentingImageFinishLayer.borderWidth];
    borderWidthAnim.duration = self.duration;
    
    CABasicAnimation* borderColorAnim = [CABasicAnimation animationWithKeyPath:@"borderColor"];
    borderColorAnim.fromValue = (id) self.presentingImageStartLayer.borderColor;
    borderColorAnim.toValue = (id) self.presentingImageFinishLayer.borderColor;
    borderColorAnim.duration = self.duration;
    
    animatedPresentingImageView.layer.cornerRadius = self.presentingImageFinishLayer.cornerRadius;
    animatedPresentingImageView.layer.borderWidth = self.presentingImageFinishLayer.borderWidth;
    animatedPresentingImageView.layer.borderColor = self.presentingImageFinishLayer.borderColor;
    animatedPresentingImageView.layer.masksToBounds = self.presentingImageFinishLayer.masksToBounds;
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.fillMode = kCAFillModeForwards;
    group.removedOnCompletion = NO;
    group.duration = self.duration;
    [group setAnimations:@[cornerRadiusAnim, borderWidthAnim, borderColorAnim]];
    group.delegate = self;
    
    
    [animatedPresentingImageView.layer addAnimation:group forKey:@"AnimateShowFrame"];
}

- (void) willAnimateHideTransition
{
    [super willAnimateHideTransition];
    
    self.presentingImageFinishFrame = [self.toVC getPresentedImage].frame;
    
    animatedPresentingImageView = [[UIImageView alloc] initWithFrame:self.presentingImageFinishFrame];
    [animatedPresentingImageView setBackgroundColor:[UIColor whiteColor]];
    
    animatedPresentingImageView.layer.cornerRadius = self.presentingImageFinishLayer.cornerRadius;
    animatedPresentingImageView.layer.masksToBounds = self.presentingImageFinishLayer.masksToBounds;
    
    [animatedPresentingImageView setImage:self.presentingImage];
    
    if (self.presentingImage.size.height / self.presentingImage.size.width > _MAX_IMAGE_RATIO) {
        [animatedPresentingImageView setContentMode:UIViewContentModeScaleAspectFit];
    } else{
        [animatedPresentingImageView setContentMode:UIViewContentModeScaleToFill];
    }
    
    
    [self.animationView addSubview:animatedPresentingImageView];
}

- (void) addHideAnimations
{
    [super addHideAnimations];
    
    animatedPresentingImageView.frame = self.presentingImageStartFrame;
    
    // Change the position explicitly.
    CABasicAnimation* cornerRadiusAnim = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
    cornerRadiusAnim.fromValue = [NSNumber numberWithFloat:self.presentingImageFinishLayer.cornerRadius];
    cornerRadiusAnim.toValue = [NSNumber numberWithFloat:self.presentingImageStartLayer.cornerRadius];
    cornerRadiusAnim.duration = self.duration;
    
    CABasicAnimation* borderWidthAnim = [CABasicAnimation animationWithKeyPath:@"borderWidth"];
    borderWidthAnim.fromValue = [NSNumber numberWithFloat:self.presentingImageFinishLayer.borderWidth];
    borderWidthAnim.toValue = [NSNumber numberWithFloat:self.presentingImageStartLayer.borderWidth];
    borderWidthAnim.duration = self.duration;
    
    CABasicAnimation* borderColorAnim = [CABasicAnimation animationWithKeyPath:@"borderColor"];
    borderColorAnim.fromValue = (id) self.presentingImageFinishLayer.borderColor;
    borderColorAnim.toValue = (id) self.presentingImageStartLayer.borderColor;
    borderColorAnim.duration = self.duration;
    
    animatedPresentingImageView.layer.cornerRadius = self.presentingImageStartLayer.cornerRadius;
    animatedPresentingImageView.layer.borderWidth = self.presentingImageStartLayer.borderWidth;
    animatedPresentingImageView.layer.borderColor = self.presentingImageStartLayer.borderColor;
    animatedPresentingImageView.layer.masksToBounds = self.presentingImageStartLayer.masksToBounds;
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.fillMode = kCAFillModeForwards;
    group.removedOnCompletion = NO;
    group.duration = self.duration;
    [group setAnimations:@[cornerRadiusAnim, borderWidthAnim, borderColorAnim]];
    group.delegate = self;
    
    
    [animatedPresentingImageView.layer addAnimation:group forKey:@"AnimateHideFrame"];
}


@end