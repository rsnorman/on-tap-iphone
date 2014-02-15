//
//  NormDraggableImageView.m
//  On Tap
//
//  Created by Ryan Norman on 1/3/14.
//  Copyright (c) 2014 Ryan Norman. All rights reserved.
//

#import "NormDraggableImageView.h"
#import "QuartzCore/CALayer.h"
#import "TestFlight.h"

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
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageWasTapped)];
        
        singleTap.numberOfTapsRequired = 1;
        [self addGestureRecognizer:singleTap];
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageWasDoubleTapped)];
        
        doubleTap.numberOfTapsRequired = 2;
        [self addGestureRecognizer:doubleTap];
        
        [singleTap requireGestureRecognizerToFail: doubleTap];
        
        UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(imageWasPinched:)];
        [self addGestureRecognizer:pinch];
        
        self.zoomedIn = NO;
        self.aspectRatio = self.image.size.height / self.image.size.height;
        
        [self.layer setMasksToBounds:YES];
    }
    return self;
}

-(void)move:(UIPanGestureRecognizer *)gesture
{
    if (!self.zoomedIn) {
        [self didStartThrow:gesture];
    } else if (self.zoomedIn) {
        [self imageWasPanned:gesture];
    }
}

- (void)imageWasPinched:(UIPinchGestureRecognizer *)sender {
    
    static CGRect initialBounds;
    
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        initialBounds = self.bounds;
        
        CGPoint locationInView = [sender locationInView:self];
        CGPoint locationInSuperview = [sender locationInView:self.superview];
        
        self.layer.anchorPoint = CGPointMake(locationInView.x / self.frame.size.width, locationInView.y / self.frame.size.height);
        
        self.center = locationInSuperview;
    }
    CGFloat factor = [sender scale];
    
    CGAffineTransform zt = CGAffineTransformScale(CGAffineTransformIdentity, factor, factor);
    self.bounds = CGRectApplyAffineTransform(initialBounds, zt);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        
        CGRect before = self.frame;
        self.layer.anchorPoint = CGPointMake(0.5, 0.5);
        
        self.frame = CGRectOffset(self.frame, before.origin.x - self.frame.origin.x, before.origin.y - self.frame.origin.y);
        
        if (self.frame.size.height - self.image.size.height > 2) {
            
            self.zoomedIn = YES;
            
            [UIView animateWithDuration:0.2
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^
             {
                 CGRect maxBounds = [self getMaximumBounds];
                 CGPoint upperLeftPoint = [self getUpperLeftCornerToFitBounds:maxBounds InView:self.delegate.view];
                 self.frame = CGRectMake(upperLeftPoint.x, upperLeftPoint.y, maxBounds.size.width, maxBounds.size.height);
             }
                             completion:nil];
            
        } else if (self.frame.size.height <= self.image.size.height && (self.frame.size.height < self.delegate.view.frame.size.height && self.frame.size.width < self.delegate.view.frame.size.width)) {
            
            self.zoomedIn = NO;
            
            [UIView animateWithDuration:0.2
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^
             {
                 CGRect minBounds = [self getMinimumBounds];
                 CGPoint upperLeftPoint = [self getUpperLeftPoint:minBounds];
                 self.frame = CGRectMake(upperLeftPoint.x, upperLeftPoint.y, minBounds.size.width, minBounds.size.height);
             }
                             completion:nil];
            
        } else {
            [UIView animateWithDuration:0.2
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^
             {
                 self.zoomedIn = true;
                 
                 CGPoint upperLeftCorner = [self getUpperLeftCornerToFitBounds:self.frame InView:self.delegate.view];
                 
                 self.frame = CGRectMake(upperLeftCorner.x, upperLeftCorner.y, self.frame.size.width, self.frame.size.height);
             }
                             completion:nil];
        }
        
        [TestFlight passCheckpoint:@"Zoomed In/Out Beer Label With Pinch"];
    }
}

- (void)imageWasTapped
{
    [TestFlight passCheckpoint:@"Dismissed Beer Label With Tap"];
    [self.delegate imageShouldBeDismissed: self];
}

- (void)imageWasDoubleTapped{
    
    if (self.frame.size.height < self.image.size.height) {
        
        self.zoomedIn = YES;
        
        [UIView animateWithDuration:0.2
                              delay:0.0
                            options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut
                         animations:^
         {
             CGRect maxBounds = [self getMaximumBounds];
             CGPoint upperLeftPoint = [self getUpperLeftPoint:maxBounds];
             self.frame = CGRectMake(upperLeftPoint.x, upperLeftPoint.y, maxBounds.size.width, maxBounds.size.height);
             
         }
                         completion:nil];
        
        [TestFlight passCheckpoint:@"Zoomed In Beer Label With Double Tap"];
        
    } else if (self.zoomedIn) {
        
        self.zoomedIn = NO;
        
        [UIView animateWithDuration:0.2
                              delay:0.0
                            options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut
                         animations:^
         {
             CGRect minBounds = [self getMinimumBounds];
             CGPoint upperLeftPoint = [self getUpperLeftPoint:minBounds];
             self.frame = CGRectMake(upperLeftPoint.x, upperLeftPoint.y, minBounds.size.width, minBounds.size.height);
             
         }
                         completion:nil];
        
        [TestFlight passCheckpoint:@"Zoomed Out Beer Label With Double Tap"];
    } else {
        [UIView animateWithDuration:0.1
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^
         {
             self.frame = CGRectMake(self.frame.origin.x - 10, self.frame.origin.y - 10, self.frame.size.width + 20, self.frame.size.height + 20);
         }
                         completion:^(BOOL finished)
         {
             [UIView animateWithDuration:0.1
                                   delay:0.0
                                 options:UIViewAnimationOptionCurveEaseInOut
                              animations:^
              {
                  self.frame = CGRectMake(self.frame.origin.x + 10, self.frame.origin.y + 10, self.frame.size.width - 20, self.frame.size.height - 20);
              }
                              completion:nil];
         }];
    }
    
    [TestFlight passCheckpoint:@"Tried Zooming In Small Beer Label With Double Tap"];
}

- (CGRect)getMaximumBounds
{
    float maxWidth = self.image.size.width;
    float maxHeight = self.image.size.height;
    
    return CGRectMake(self.frame.origin.x + ((self.frame.size.width - maxWidth) / 2), self.frame.origin.y + ((self.frame.size.height - maxHeight) / 2), maxWidth, maxHeight);
}

- (CGRect)getMinimumBounds
{
    float minWidth = self.image.size.width;
    float minHeight = self.image.size.height;
    
    if (minWidth > self.delegate.view.frame.size.width) {
        minHeight = minHeight * self.delegate.view.frame.size.width / minWidth;
        minWidth = self.delegate.view.frame.size.width;
    }
    
    if (minHeight > self.delegate.view.frame.size.height) {
        minWidth = minWidth * self.delegate.view.frame.size.height / minHeight;
        minHeight = self.delegate.view.frame.size.height;
    }
    
    return CGRectMake(self.frame.origin.x + ((self.frame.size.width - minWidth) / 2), self.frame.origin.y + ((self.frame.size.height - minHeight) / 2), minWidth, minHeight);
}

- (CGPoint)getUpperLeftPoint:(CGRect)bounds
{
    float paddingTop = (self.delegate.view.frame.size.height - bounds.size.height) / 2;
    float paddingLeft = (self.delegate.view.frame.size.width - bounds.size.width) / 2;
    return CGPointMake(paddingLeft, paddingTop);
}

- (void)didStartThrow:(UIPanGestureRecognizer *)gesture
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
                 [self.delegate imageShouldBeDismissed: self];
             }];
            
            [TestFlight passCheckpoint:@"Dismissed Beer Label with Throw"];
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
                             completion:nil];
            
            [TestFlight passCheckpoint:@"Failed Dismissing Beer Label with Throw"];
        }
        
        
    }
}

- (void)imageWasPanned:(UIPanGestureRecognizer *)gesture
{
    static float startX;
    static float startY;
    static CGPoint translatedPoint;
    
    translatedPoint = [(UIPanGestureRecognizer*)gesture translationInView:self.delegate.view];
    
    if ([(UIPanGestureRecognizer*)gesture state] == UIGestureRecognizerStateBegan) {
        startX = [self center].x;
        startY = [self center].y;
    } else if ([(UIPanGestureRecognizer*)gesture state] == UIGestureRecognizerStateChanged) {
        translatedPoint = CGPointMake(startX + translatedPoint.x, startY + translatedPoint.y);
        
        [self setCenter:translatedPoint];
    } else if ([(UIPanGestureRecognizer*)gesture state] == UIGestureRecognizerStateEnded) {
        
        
        CGPoint velocity = [gesture velocityInView:gesture.view];
        
        // Apply damping to get final spot
        // Ideally you'll want to scale this by some magnification factor
        CGPoint translation = CGPointMake( velocity.x / 20.0, velocity.y / 20.0);
        
        // If the user is close to still, animation just looks wanky
        if (fabs(translation.x) < 15. && fabs(translation.y) < 15.) {
            translation.x = 0;
            translation.y = 0;
        }
        
        // Using a consistent duration keeps fast events fast because there is more space to move in the same amount of time.
        // Use the ease out option to slow it down more at the end than at the beginning.
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            gesture.view.transform = CGAffineTransformTranslate(gesture.view.transform, translation.x, translation.y);
            
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:0.2
                                  delay:0.0
                                options:UIViewAnimationTransitionNone | UIViewAnimationOptionCurveEaseInOut
                             animations:^
             {
                 CGPoint upperLeftCorner = [self getUpperLeftCornerToFitBounds:self.frame InView:self.delegate.view];

                 self.frame = CGRectMake(upperLeftCorner.x, upperLeftCorner.y, self.frame.size.width, self.frame.size.height);
            } completion:nil];
        }];
    }
}

-(CGPoint)getUpperLeftCornerToFitBounds:(CGRect)bounds InView:(UIView *)view
{
    float paddingLeft = bounds.origin.x;
    float paddingTop = bounds.origin.y;
    
    if (bounds.size.height > view.frame.size.height) {
        if (bounds.origin.y > 0) {
            paddingTop = 0;
        } else if (bounds.origin.y + bounds.size.height < view.frame.size.height) {
            paddingTop = view.frame.size.height - bounds.size.height;
        }
    } else {
        paddingTop = (view.frame.size.height - bounds.size.height) / 2;
    }
    
    if (bounds.size.width > view.frame.size.width) {
        if (bounds.origin.x > 0) {
            paddingLeft = 0;
        } else if (bounds.origin.x + bounds.size.width < view.frame.size.width) {
            paddingLeft = view.frame.size.width - bounds.size.width;
        }
    } else {
        paddingLeft = (view.frame.size.width - bounds.size.width) / 2;
    }
    
    return CGPointMake(paddingLeft, paddingTop);
}

@end
