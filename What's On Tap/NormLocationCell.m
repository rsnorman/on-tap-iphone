//
//  NormLocationRowView.m
//  On Tap
//
//  Created by Ryan Norman on 1/14/14.
//  Copyright (c) 2014 Ryan Norman. All rights reserved.
//

#import "NormLocationCell.h"
#import "QuartzCore/CALayer.h"

@implementation NormLocationCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {     
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, self.frame.size.width - 30, 45)];
        [self.nameLabel setTextColor:[UIColor whiteColor]];
        [self.nameLabel setFont:[UIFont boldSystemFontOfSize:20.0]];
        [self addSubview:self.nameLabel];
        
        self.inventoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 25, self.frame.size.width - 30, 35)];
        [self.inventoryLabel setTextColor:[UIColor lightGrayColor]];
        [self.inventoryLabel setFont:[UIFont systemFontOfSize:15.0]];
        [self addSubview:self.inventoryLabel];
        
        self.distanceAwayLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 45, self.frame.size.width - 30, 35)];
        [self.distanceAwayLabel setTextColor:[UIColor lightGrayColor]];
        [self.distanceAwayLabel setFont:[UIFont systemFontOfSize:15.0]];
        [self addSubview:self.distanceAwayLabel];
        
        [[self contentView] setBackgroundColor:[UIColor clearColor]];
        [[self backgroundView] setBackgroundColor:[UIColor clearColor]];
        [self setBackgroundColor:[UIColor clearColor]];
        
    }
    return self;
}

- (void) displayLabel
{
    [self.nameLabel setText:self.location.name];
    [self.inventoryLabel setText: self.location.inventory];
    [self.distanceAwayLabel setText: self.location.distanceAway];
    
}

- (void)setHighlighted: (BOOL)highlighted animated: (BOOL)animated
{
    
}

- (void)setSelected: (BOOL)selected animated: (BOOL)animated
{
    // don't select
    //[super setSelected:selected animated:animated];
}

@end
