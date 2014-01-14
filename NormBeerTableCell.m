//
//  NormBeerTableCell.m
//  What's On Tap
//
//  Created by Ryan Norman on 11/29/13.
//  Copyright (c) 2013 Ryan Norman. All rights reserved.
//

#import "NormBeerTableCell.h"
#import "NormImageCache.h"

@implementation NormBeerTableCell

@synthesize nameLabel = _nameLabel;
@synthesize breweryLabel = _breweryLabel;
@synthesize detailsLabel = _detailsLabel;
@synthesize costLabel = _costLabel;
@synthesize imageView = _imageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.imageView = [[NormImageView alloc] initWithFrame:CGRectMake(5, 7, 60, 60)];
        [self addSubview:self.imageView];
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(73, 7, 204, 21)];
        self.nameLabel.font = [UIFont boldSystemFontOfSize:17.0];
        [self.nameLabel setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:self.nameLabel];
        
        self.breweryLabel = [[UILabel alloc] initWithFrame:CGRectMake(73, 26, 204, 21)];
        self.breweryLabel.font = [UIFont systemFontOfSize:14.0];
        self.breweryLabel.textColor = [UIColor darkTextColor];
        [self.nameLabel setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:self.breweryLabel];
        
        self.detailsLabel = [[UILabel alloc] initWithFrame:CGRectMake(73, 44, 204, 21)];
        self.detailsLabel.font = [UIFont systemFontOfSize:13.0];
        self.detailsLabel.textColor = [UIColor lightGrayColor];
        [self.nameLabel setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:self.detailsLabel];
    
        self.costLabel = [[NormPriceLabel alloc] initWithFrame:CGRectMake(285, 23, 31, 31)];
        [self addSubview:self.costLabel];
    }
    return self;
}

- (void)setBeer:(NormBeer *)beer
{
    self.nameLabel.text = beer.name;
    self.breweryLabel.text = beer.breweryName;
    [self.costLabel setPrice:beer.price];
    self.detailsLabel.text = [[NSArray arrayWithObjects:beer.servedIn, @" - ", [NSString stringWithFormat:@"%g%% ABV", beer.abv], nil] componentsJoinedByString:@" "];
    
    [self.imageView setURLForImage:[[beer.label objectForKey:@"thumbnail"] objectForKey:@"url"]  defaultImage: [UIImage imageNamed: [beer.serveType isEqual: @"Bottles"] ? @"bottle.png" : [beer.serveType isEqual: @"Bottles"] ? @"can.png" : @"glass.png"]];
}

@end
