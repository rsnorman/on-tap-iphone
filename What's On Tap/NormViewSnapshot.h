//
//  NormViewSnapshot.h
//  On Tap
//
//  Created by Ryan Norman on 1/12/14.
//  Copyright (c) 2014 Ryan Norman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NormViewSnapshot : NSObject

+ (UIImage*)snapshotOfWindow:(UIView *)view;
+ (UIImage*)snapshotOfView:(UIView *) view;
+ (UIImage*)blurredSnapshotOfView:(UIView *) view;

@end
