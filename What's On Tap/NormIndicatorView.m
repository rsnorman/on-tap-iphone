//
//  NormIndicatorView.m
//  On Tap
//
//  Created by Ryan Norman on 1/30/14.
//  Copyright (c) 2014 Ryan Norman. All rights reserved.
//

#import "NormIndicatorView.h"

@implementation NormIndicatorView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.spinner setBackgroundColor:[UIColor whiteColor]];
        [self.spinner startAnimating];
        [self.spinner setCenter: CGPointMake(frame.size.width / 2, frame.size.height / 2)];
        [self addSubview:self.spinner];
        
        self.messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 90)];
        [self.messageLabel setText:@"Loading…"];
        [self.messageLabel setTextAlignment:NSTextAlignmentCenter];
        [self.messageLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [self.messageLabel setNumberOfLines:4];
        [self addSubview:self.messageLabel];
    }
    return self;
}

- (void)startAnimating
{
    [self.spinner startAnimating];
}

- (void)stopAnimating
{
    [self.spinner stopAnimating];
}

- (void)setMessage:(NSString *)message
{
    [self.messageLabel setText:message];
}

- (void)setHidden:(BOOL)hidden
{
    self.layer.opacity = hidden ? 1.0 : 0.0;
    
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.layer.opacity = hidden ? 0.0 : 1.0;
    } completion:^(BOOL finished) {
        [super setHidden:hidden];
    }];
}

@end
