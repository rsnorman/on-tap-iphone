//
//  NormBeerTableCell.h
//  What's On Tap
//
//  Created by Ryan Norman on 11/29/13.
//  Copyright (c) 2013 Ryan Norman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NormBeer.h"
#import "NormPriceLabel.h"
#import "NormImageCache.h"

@interface NormBeerTableCell : UITableViewCell

@property (nonatomic) UILabel *nameLabel;
@property (nonatomic) UILabel *breweryLabel;
@property (nonatomic) UILabel *detailsLabel;
@property (nonatomic) NormPriceLabel *costLabel;
@property (nonatomic) UIImageView *imageView;
@property (nonatomic) NormImageCache *imageCache;

- (void)setBeer:(NormBeer *)beer;

@end
