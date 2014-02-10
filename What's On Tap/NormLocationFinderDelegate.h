//
//  NormLocationFinderDelegate.h
//  On Tap
//
//  Created by Ryan Norman on 1/14/14.
//  Copyright (c) 2014 Ryan Norman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Location.h"

@protocol NormLocationFinderDelegate <NSObject>

- (void) setLocation:(Location *)location;

@end
