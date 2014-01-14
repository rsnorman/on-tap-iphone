//
//  TransitionDelegate.h
//  CustomTransitionExample
//
//  Created by Blanche Faur on 10/24/13.
//  Copyright (c) 2013 Blanche Faur. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NormModalTransitionDelegate.h"

@interface NormImageModalTransitionDelegate : NormModalTransitionDelegate

@property UIImage *transitionImage;
@property CGRect startFrame;
@property CGRect finishFrame;
@property CALayer *startLayer;
@property CALayer *finishLayer;

@end