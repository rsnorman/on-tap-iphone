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
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 7, 60, 60)];
        [self.imageView setBackgroundColor:[UIColor whiteColor]];
        [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [self.imageView setOpaque:YES];
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
    
        
        CALayer *imageLayer = self.imageView.layer;
        [imageLayer setCornerRadius:30];
        [imageLayer setBorderWidth:1];
        [imageLayer setBorderColor:[UIColor colorWithRed:201.0/255.0 green:201.0/255.0 blue:201.0/255.0 alpha:1.0].CGColor];
        [imageLayer setMasksToBounds:YES];
        [imageLayer setBackgroundColor:[UIColor whiteColor].CGColor];
        
        
        self.costLabel = [[NormPriceLabel alloc] initWithFrame:CGRectMake(285, 23, 31, 31)];
        [self addSubview:self.costLabel];
        
        self.imageCache = [[NormImageCache alloc] init];
    }
    return self;
}

- (void)setBeer:(NormBeer *)beer
{
    self.nameLabel.text = beer.name;
    self.breweryLabel.text = beer.breweryName;
    [self.costLabel setPrice:beer.price];
    self.detailsLabel.text = [[NSArray arrayWithObjects:beer.servedIn, @" - ", [NSString stringWithFormat:@"%g%% ABV", beer.abv], nil] componentsJoinedByString:@" "];
    
    if (beer.label.length != 0){
        
        UIImage *image = [self.imageCache imageForKey:beer.label];
        
        if (image)
        {
            self.imageView.image = image;
            
            if (image.size.height / image.size.width > 1.5) {
                [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
            } else{
                [self.imageView setContentMode:UIViewContentModeScaleToFill];
            }
        }
        else {
            
            if ([beer.serveType  isEqual: @"On Tap"]) {
                [self.imageView setImage:[UIImage imageNamed: @"glass.png"]];
            } else if ([beer.serveType  isEqual: @"Bottles"]) {
                [self.imageView setImage:[UIImage imageNamed: @"bottle"]];
            } else if ([beer.serveType isEqual:@"Cans"]) {
                [self.imageView setImage:[UIImage imageNamed: @"can"]];
            } else {
                [self.imageView setImage:[UIImage imageNamed: @"glass.png"]];
            }
            
            // get the UIImage
            [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:beer.label]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                self.imageView.image = [UIImage imageWithData:data];
                if (image.size.height / image.size.width > 1.5) {
                    [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
                } else{
                    [self.imageView setContentMode:UIViewContentModeScaleToFill];
                }
                [self.imageCache setImage:self.imageView.image forKey:beer.label];
            }];
        }
    } else {
        if ([beer.serveType  isEqual: @"On Tap"]) {
            [self.imageView setImage:[UIImage imageNamed: @"glass.png"]];
        } else if ([beer.serveType  isEqual: @"Bottles"]) {
            [self.imageView setImage:[UIImage imageNamed: @"bottle"]];
        } else if ([beer.serveType isEqual:@"Cans"]) {
            [self.imageView setImage:[UIImage imageNamed: @"can"]];
        } else {
            [self.imageView setImage:[UIImage imageNamed: @"glass.png"]];
        }
    }
}

@end
