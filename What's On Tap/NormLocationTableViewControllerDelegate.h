//
//  NormLocationTableViewControllerDelegate.h
//  On Tap
//
//  Created by Ryan Norman on 2/8/14.
//  Copyright (c) 2014 Ryan Norman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Location.h"

@protocol NormLocationTableViewControllerDelegate <NSObject>

@optional
- (void)didSelectLocation:(Location *)selectedLocation;
- (void)didSelectLocationMap:(Location *)location;
@end
