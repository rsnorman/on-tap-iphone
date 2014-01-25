//
//  NormLocationFinderController.h
//  On Tap
//
//  Created by Ryan Norman on 1/14/14.
//  Copyright (c) 2014 Ryan Norman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NormLocationFinderDelegate.h"


@interface NormLocationFinderController : UIViewController
@property id <NormLocationFinderDelegate> delegate;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@end
