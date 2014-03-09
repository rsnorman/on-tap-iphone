//
//  NormIndicatorView.m
//  On Tap
//
//  Created by Ryan Norman on 1/30/14.
//  Copyright (c) 2014 Ryan Norman. All rights reserved.
//

#import "NormIndicatorView.h"
#import "FBShimmeringView.h"
@interface NormIndicatorView ()

@property CGPoint startCenter;
@property FBShimmeringView *shimmeringView;
@end

@implementation NormIndicatorView

- (id)initWithFrame:(CGRect)frame
{
    frame = CGRectOffset(frame, 0, -10);
    self = [super initWithFrame:frame];
    if (self) {
        self.messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, frame.size.width - 20, frame.size.height - 10)];
        [self.messageLabel setText:@"Loading…"];
        [self.messageLabel setTextAlignment:NSTextAlignmentCenter];
        [self.messageLabel setFont:[UIFont systemFontOfSize:20.0f]];
        [self.messageLabel setNumberOfLines:0];
        [self.messageLabel setTextColor:[UIColor whiteColor]];

        [self addSubview:self.messageLabel];
        
        _shimmeringView = [[FBShimmeringView alloc] initWithFrame:self.messageLabel.bounds];
        [self addSubview:_shimmeringView];
        
        _shimmeringView.contentView = self.messageLabel;
        
        // Start shimmering.
        _shimmeringView.shimmering = YES;
        
        _startCenter = self.center;
    }
    return self;
}

- (void)setCenter:(CGPoint)center
{
    _startCenter = CGPointMake(center.x, center.y - 10);
    [super setCenter:_startCenter];
    
}

- (void)startAnimating
{
    _shimmeringView.shimmering = YES;
    [self setHidden:NO];
    self.layer.opacity = 0.0;
    self.center = _startCenter;
    
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.layer.opacity = 0.7;
                     }
                     completion:^(BOOL finished) {
    
                     }];
}

- (void)stopAnimating
{
    _shimmeringView.shimmering = NO;
    
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.layer.opacity = 0.0;
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

- (void)stopAnimatingWithSuccessMessage:(NSString *)successMessage withDelay:(float)delay
{
    [self setMessage:successMessage];
    
    _shimmeringView.shimmering = NO;
    
    [UIView animateWithDuration:1.0
                          delay:delay
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.layer.opacity = 0.0;
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

- (void)setMessage:(NSString *)message
{
    self.messageLabel.frame = CGRectMake(10, 10, self.frame.size.width - 20, self.frame.size.height - 20);
    [self.messageLabel setText:message];
    [self.messageLabel sizeToFit];
    self.shimmeringView.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.messageLabel.frame.size.width + 20, self.messageLabel.frame.size.height + 20);

    self.messageLabel.center = CGPointMake(self.frame.size.width / 2, self.messageLabel.center.y);
    self.shimmeringView.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);

    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.messageLabel.frame.size.height + 20);
    } completion:nil];
}

- (void)setErrorMessage:(NSString *)errorMessage
{
    [self setMessage:errorMessage];
    
    _shimmeringView.shimmering = NO;
    
    if (self.layer.opacity == 0) {
        [UIView animateWithDuration:0.5
                              delay:0.0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             self.layer.opacity = 0.7;
                         }
                         completion:^(BOOL finished) {
                             
                         }];
    }
}

@end
