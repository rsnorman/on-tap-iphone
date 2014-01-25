//
//  Menu.h
//  On Tap
//
//  Created by Ryan Norman on 1/25/14.
//  Copyright (c) 2014 Ryan Norman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Beer;

@interface Menu : NSManagedObject

@property (nonatomic, retain) NSString * locationId;
@property (nonatomic, retain) NSDate * createdOn;
@property (nonatomic, retain) NSString * mID;
@property (nonatomic, retain) NSSet *beers;
@end

@interface Menu (CoreDataGeneratedAccessors)

- (void)addBeersObject:(Beer *)value;
- (void)removeBeersObject:(Beer *)value;
- (void)addBeers:(NSSet *)values;
- (void)removeBeers:(NSSet *)values;

@end
