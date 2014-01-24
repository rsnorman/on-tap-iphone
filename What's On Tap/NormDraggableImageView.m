//
//  NormDraggableImageView.m
//  On Tap
//
//  Created by Ryan Norman on 1/3/14.
//  Copyright (c) 2014 Ryan Norman. All rights reserved.
//

#import "NormDraggableImageView.h"
#import "QuartzCore/CALayer.h"

@implementation NormDraggableImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        
        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
        [panRecognizer setMinimumNumberOfTouches:1];
        [panRecognizer setMaximumNumberOfTouches:1];
        [self addGestureRecognizer:panRecognizer];
        
        [self.layer setCornerRadius:5.0];
        [self.layer setMasksToBounds:YES];
    }
    return self;
}

-(void)move:(UIPanGestureRecognizer *)gesture
{
    static CGPoint lastTranslate;   // the last value
    static CGPoint prevTranslate;   // the value before that one
    
    CGPoint translate = [gesture translationInView:self.superview];
    
    
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        lastTranslate = translate;
        prevTranslate = lastTranslate;
    }
    else if (gesture.state == UIGestureRecognizerStateChanged)
    {
        prevTranslate = lastTranslate;
        lastTranslate = translate;
        
        self.frame = CGRectOffset(self.frame, translate.x - prevTranslate.x, translate.y - prevTranslate.y);
    }
    else if (gesture.state == UIGestureRecognizerStateEnded)
    {
        CGPoint swipeVelocity = [gesture velocityInView:self.superview];
        
        if (sqrt(pow(swipeVelocity.x, 2) + pow(swipeVelocity.y, 2)) > 1500) {
            float inertiaSeconds = 0.2f;  // let's calculate where that flick would take us this far in the future
            CGPoint final = CGPointMake(translate.x + swipeVelocity.x * inertiaSeconds, translate.y + swipeVelocity.y * inertiaSeconds);
            
            
            [UIView animateWithDuration:inertiaSeconds
                                  delay:0.0
                                options:UIViewAnimationTransitionNone | UIViewAnimationOptionCurveLinear
                             animations:^
             {
                 
                 CGRect frame = self.frame;
                 frame.origin.x = final.x;
                 frame.origin.y = final.y;
                 
                 self.frame = frame;
             }
                             completion:^(BOOL finished)
             {
                 [self.delegate imageShouldBeThrownOffScreen: self];
             }];
        } else {
            
            [UIView animateWithDuration:0.1
                                  delay:0.0
                                options:UIViewAnimationTransitionNone | UIViewAnimationOptionCurveEaseInOut
                             animations:^
             {
                 
                 CGRect frame = self.frame;
                 frame.origin.x = (self.superview.frame.size.width - self.frame.size.width) / 2;
                 frame.origin.y = (self.superview.frame.size.height - self.frame.size.height) / 2;
                 
                 self.frame = frame;
             }
                             completion:^(BOOL finished)
             {

             }];
            
            
        }
        

    }
}

@end
