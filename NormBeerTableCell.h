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
#import "NormImageView.h"

// Table cell for displaying information about an individual beer. Contains name of the beer,
// name of the brewery that makes the beer, extra useful details about the beer, and the price.
// Also shows a label if one is available, otherwise a default image is visible.
@interface NormBeerTableCell : UITableViewCell

// Label for the name of the beer
@property (nonatomic) UILabel *nameLabel;

// Label for the name of the brewery that makes the beer
@property (nonatomic) UILabel *breweryLabel;

// Label for holding details about the beer like abv and serving container
@property (nonatomic) UILabel *detailsLabel;

// Price label for holding price of beer
@property (nonatomic) NormPriceLabel *costLabel;

// Image for holding beer label
@property (nonatomic) NormImageView *imageView;

// Sets the beer that will be displayed in the cell
- (void)setBeer:(NormBeer *)beer;

@end
