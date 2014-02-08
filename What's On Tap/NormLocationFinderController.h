//
//  NormLocationFinderController.h
//  On Tap
//
//  Created by Ryan Norman on 1/14/14.
//  Copyright (c) 2014 Ryan Norman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NormLocationFinderDelegate.h"
#import "Location.h"


@interface NormLocationFinderController : UIViewController
@property id <NormLocationFinderDelegate> delegate;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property BOOL isUpdatingLocations;
@property BOOL isAnimating;
@property int displayCount;
@property BOOL delayCellDisplay;
@property Location *selectedLocation;

@property BOOL shouldHideStatusBar;
@end
