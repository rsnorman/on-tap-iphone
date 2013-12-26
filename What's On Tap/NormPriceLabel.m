//
//  NormPriceLabel.m
//  On Tap
//
//  Created by Ryan Norman on 12/25/13.
//  Copyright (c) 2013 Ryan Norman. All rights reserved.
//

#import "NormPriceLabel.h"

@implementation NormPriceLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:13.0]];
        [self setTextColor:[UIColor whiteColor]];
        [self setTextAlignment:NSTextAlignmentCenter];
        [self setPersistentBackgroundColor:[UIColor colorWithRed:198.0/255.0 green:56.0/255.0 blue:32.0/255.0 alpha:1.0]];
        
        CALayer *priceLayer = self.layer;
        [priceLayer setCornerRadius:MAX(frame.size.width, frame.size.height)/2];
        [priceLayer setMasksToBounds:YES];
        [priceLayer setBackgroundColor:[UIColor whiteColor].CGColor];
    }
    return self;
}

- (void)setPrice:(float)price
{
    [self setText:[NSString stringWithFormat:@"$%g", price]];
}

- (void)setPersistentBackgroundColor:(UIColor*)color {
    super.backgroundColor = color;
}

- (void)setBackgroundColor:(UIColor *)color {
    // do nothing - background color never changes
}

@end
