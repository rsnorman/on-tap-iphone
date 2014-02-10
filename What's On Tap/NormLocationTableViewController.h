//
//  NormLocationTableViewController.h
//  On Tap
//
//  Created by Ryan Norman on 2/8/14.
//  Copyright (c) 2014 Ryan Norman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NormLocationTableViewControllerDelegate.h"

@interface NormLocationTableViewController : UITableViewController

@property int displayCount;
@property BOOL isAnimating;
@property NSTimeInterval delayCellDisplay;
@property id<NormLocationTableViewControllerDelegate> delegate;

- (void) setLocations:(NSArray *)locations;

@end
