//
//  AnimatedTransitioning.h
//  CustomTransitionExample
//
//  Created by Blanche Faur on 10/24/13.
//  Copyright (c) 2013 Blanche Faur. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NormModalHideTransitioning : NSObject <UIViewControllerAnimatedTransitioning>


@property (nonatomic, assign) BOOL isPresenting;
@property (nonatomic, assign) UIViewController *toVC;
@property (nonatomic, assign) UIViewController *fromVC;
@property (nonatomic, assign) float duration;
@property (nonatomic, assign) float zoomOutPercentage;
@property (nonatomic, assign) UIImage *bgImage;
@property (nonatomic, assign) UIImage *blurredBgImage;

- (id) initWithFromController:(UIViewController *)fromVC toController:(UIViewController *)toVC;

@end