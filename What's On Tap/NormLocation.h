//
//  NormLocation.h
//  On Tap
//
//  Created by Ryan Norman on 1/14/14.
//  Copyright (c) 2014 Ryan Norman. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Location.h"

@interface NormLocation : Location

+ (void)fetch:(void (^)(NSArray *))action failedWithError:(void (^)(NSError *))errorAction;

@end
