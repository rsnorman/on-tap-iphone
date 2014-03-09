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
        [self setFont:[UIFont fontWithName:_SECONDARY_FONT size:13.0]];
        [self setTextColor:[UIColor whiteColor]];
        [self setTextAlignment:NSTextAlignmentCenter];
        [self setPersistentBackgroundColor:_MAIN_COLOR];
        
        CALayer *priceLayer = self.layer;
        [priceLayer setCornerRadius:MAX(frame.size.width, frame.size.height)/2];
        [priceLayer setMasksToBounds:YES];
        [priceLayer setBackgroundColor:[UIColor whiteColor].CGColor];
    }
    return self;
}

- (void)setPrice:(float)price
{
    if (price != 0.0) {
        [self setText:[NSString stringWithFormat:@"$%g", price]];
    } else {
        [self setText:@"ask"];
    }
}


- (void)setPersistentBackgroundColor:(UIColor*)color {
    super.backgroundColor = color;
}

- (void)setBackgroundColor:(UIColor *)color {
    // do nothing - background color never changes
}

@end
