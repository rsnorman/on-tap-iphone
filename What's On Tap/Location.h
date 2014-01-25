//
//  Location.h
//  On Tap
//
//  Created by Ryan Norman on 1/25/14.
//  Copyright (c) 2014 Ryan Norman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Menu;

@interface Location : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * lID;
@property (nonatomic, retain) NSSet *menus;

+ (NSArray *)fetch;
+ (void)fetchFromServer:(void (^)(NSArray *))action failedWithError:(void (^)(NSError *))errorAction;

@end

@interface Location (CoreDataGeneratedAccessors)

- (void)addMenusObject:(Menu *)value;
- (void)removeMenusObject:(Menu *)value;
- (void)addMenus:(NSSet *)values;
- (void)removeMenus:(NSSet *)values;

@end
