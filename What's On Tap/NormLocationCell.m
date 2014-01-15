//
//  NormLocationRowView.m
//  On Tap
//
//  Created by Ryan Norman on 1/14/14.
//  Copyright (c) 2014 Ryan Norman. All rights reserved.
//

#import "NormLocationCell.h"

@implementation NormLocationCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 45)];
    }
    return self;
}

- (void)didMoveToSuperview
{
    [self.nameLabel setText:self.location.name];
}


@end
