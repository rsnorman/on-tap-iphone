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
        
    }
    return self;
}

- (void)setBeer:(NormBeer *)beer
{
    NormImageCache *imageCache = [[NormImageCache alloc] init];
    self.beer = beer;
    self.nameLabel.text = beer.name;
    self.breweryLabel.text = beer.breweryName;
    self.costLabel.text = [NSString stringWithFormat:@"$%g", beer.price];
    self.detailsLabel.text = [[NSArray arrayWithObjects:beer.servedIn, @" - ", [NSString stringWithFormat:@"%g%% ABV", beer.abv], nil] componentsJoinedByString:@" "];
    
    CALayer *imageLayer = self.imageView.layer;
    [imageLayer setCornerRadius:30];
    [imageLayer setBorderWidth:1];
    [imageLayer setBorderColor:[UIColor colorWithRed:201.0/255.0 green:201.0/255.0 blue:201.0/255.0 alpha:1.0].CGColor];
    [imageLayer setMasksToBounds:YES];
    
    if (beer.label.length != 0){
        
        UIImage *image = [imageCache imageForKey:beer.label];
        
        if (image)
        {
            self.imageView.image = image;
        }
        else {
            
            if ([beer.serveType  isEqual: @"On Tap"]) {
                [self.imageView setImage:[UIImage imageNamed: @"tap-highlight.png"]];
            } else if ([beer.serveType  isEqual: @"Bottles"]) {
                [self.imageView setImage:[UIImage imageNamed: @"bottle-highlight.png"]];
            } else {
                [self.imageView setImage:[UIImage imageNamed: @"can-highlight.png"]];
            }
            
            // get the UIImage
            [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:beer.label]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                self.imageView.image = [UIImage imageWithData:data];
                [imageCache setImage:self.imageView.image forKey:beer.label];
            }];
        }
    } else {
        if ([beer.serveType  isEqual: @"On Tap"]) {
            [self.imageView setImage:[UIImage imageNamed: @"tap-highlight.png"]];
        } else if ([beer.serveType  isEqual: @"Bottles"]) {
            [self.imageView setImage:[UIImage imageNamed: @"bottle-highlight.png"]];
        } else {
            [self.imageView setImage:[UIImage imageNamed: @"can-highlight.png"]];
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
//    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
