//
//  NormLocationRowView.h
//  On Tap
//
//  Created by Ryan Norman on 1/14/14.
//  Copyright (c) 2014 Ryan Norman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Location.h"

@protocol NormLocationCellDelegate <NSObject>

- (void)didSelectLocationMap:(Location *)location;

@end

@interface NormLocationCell : UITableViewCell

@property Location *location;
@property UILabel *nameLabel;
@property UILabel *inventoryLabel;
@property UILabel *distanceAwayLabel;
@property id<NormLocationCellDelegate> delegate;

- (void) displayLabel;
@end