//
//  NormLocationRowView.m
//  On Tap
//
//  Created by Ryan Norman on 1/14/14.
//  Copyright (c) 2014 Ryan Norman. All rights reserved.
//

#import "NormLocationCell.h"

@implementation NormLocationCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 250, 45)];
        [self.nameLabel setTextColor:[UIColor whiteColor]];
        [self.nameLabel setFont:[UIFont boldSystemFontOfSize:20.0]];
        [self addSubview:self.nameLabel];
        
        self.addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 250, 45)];
        [self.addressLabel setTextColor:[UIColor lightGrayColor]];
        [self.addressLabel setFont:[UIFont systemFontOfSize:15.0]];
        [self addSubview:self.addressLabel];
        
        [[self contentView] setBackgroundColor:[UIColor clearColor]];
        [[self backgroundView] setBackgroundColor:[UIColor clearColor]];
        [self setBackgroundColor:[UIColor clearColor]];
        
    }
    return self;
}

- (void) displayLabel
{
    [self.nameLabel setText:self.location.name];
    [self.addressLabel setText: self.location.address];
    
}

@end
