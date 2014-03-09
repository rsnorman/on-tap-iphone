//
//  NormStyleMenu.h
//  On Tap
//
//  Created by Ryan Norman on 2/10/14.
//  Copyright (c) 2014 Ryan Norman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "REMenu.h"
#import "Location.h"
#import "NormStyleMenuDelegate.h"

@interface NormServeTypeMenu : REMenu

@property NSArray *beerServeTypes;
@property (readonly) NSInteger addedBeerCount;
@property Location *currentLocation;
@property id<NormServeTypeMenuDelegate> delegate;
@property REMenuItem *locationMenuItem;
@property (retain, nonatomic) REMenuItem *addedBeerMenuItem;

- (void)setServeTypes:(NSArray *)serveTypes withBeerCounts:(NSArray *)beerCounts;
- (void)setLocation:(Location *)location;
@end
