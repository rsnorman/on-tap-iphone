//
//  NormLocation.h
//  On Tap
//
//  Created by Ryan Norman on 1/14/14.
//  Copyright (c) 2014 Ryan Norman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NormLocation : NSObject

@property NSString *name;
@property NSString *locationId;
@property NSString *type;
@property NSString *address;

+ (void)fetch:(void (^)(NSArray *))action failedWithError:(void (^)(NSError *))errorAction;

@end
