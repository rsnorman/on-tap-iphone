//
//  NormBeerTableCell.h
//  What's On Tap
//
//  Created by Ryan Norman on 11/29/13.
//  Copyright (c) 2013 Ryan Norman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NormBeer.h"
#import "NormImageCache.h"

@interface NormBeerTableCell : UITableViewCell

@property UILabel *nameLabel;
@property UILabel *breweryLabel;
@property UILabel *detailsLabel;
@property UILabel *costLabel;
@property UIImageView *imageView;

//@property (nonatomic) NormBeer *beer;
@property NormImageCache *imageCache;

- (void)setBeer:(NormBeer *)beer;
//- (void)setImageCache:(NormImageCache *)imageCache;
@end
