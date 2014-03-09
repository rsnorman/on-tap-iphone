//
//  User.h
//  On Tap
//
//  Created by Ryan Norman on 1/28/14.
//  Copyright (c) 2014 Ryan Norman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Location;

@interface User : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) Location *currentLocation;
@property (nonatomic, retain) NSString *groupPreference;
@property (nonatomic, retain) NSString *sortPreference;

+ (User *)current;
- (void)save;
@end
