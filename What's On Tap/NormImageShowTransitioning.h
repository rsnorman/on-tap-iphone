//
//  AnimatedTransitioning.h
//  CustomTransitionExample
//
//  Created by Blanche Faur on 10/24/13.
//  Copyright (c) 2013 Blanche Faur. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NormModalShowTransitioning.h"
#import "NormImageModalController.h"

@interface NormImageShowTransitioning : NormModalShowTransitioning

@property (nonatomic, assign) NormImageModalController <NormModalControllerDelegate> *toVC;
@property (nonatomic, assign) UIImage *presentingImage;
@property (nonatomic, assign) CGRect presentingImageStartFrame;
@property (nonatomic, assign) CGRect presentingImageFinishFrame;
@property (nonatomic, assign) CALayer *presentingImageStartLayer;
@property (nonatomic, assign) CALayer *presentingImageFinishLayer;

@end