//
//  NormLocationDetailsView.h
//  On Tap
//
//  Created by Ryan Norman on 2/15/14.
//  Copyright (c) 2014 Ryan Norman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Location.h"

@protocol NormLocationDetailsViewDelegate <NSObject>

- (void) didSelectViewLocationMenu;

@end

@interface NormLocationDetailsView : UIView

@property id<NormLocationDetailsViewDelegate> delegate;
@property (retain, nonatomic, readonly) Location *location;
@property (readonly) BOOL hidden;
@property CLLocation *currentLocation;
@property (retain, nonatomic) UILabel *locationNameLabel;
@property (retain, nonatomic) UILabel *locationAddressLabel;
@property (retain, nonatomic) UILabel *locationAvailableLabel;
@property (retain, nonatomic) UILabel *locationDistanceLabel;

- (void) setLocation:(Location *)location;

@end
