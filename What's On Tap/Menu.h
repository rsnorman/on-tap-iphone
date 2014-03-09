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
@class Location;

typedef enum {
    MenuGroupStyle = 0,
    MenuGroupBrewery = 1,
    MenuGroupNone = 2
} MenuGrouping;

typedef enum {
    MenuSortName = 0,
    MenuSortAbvLowToHigh = 1,
    MenuSortAbvHighToLow = 2,
    MenuSortPriceLowToHigh = 3,
    MenuSortPriceHighToLow = 4
} MenuSorting;

@interface Menu : NSManagedObject

@property (nonatomic, retain) NSString * locationId;
@property (nonatomic, retain) NSDate * createdOn;
@property (nonatomic, retain) NSString * mID;
@property (nonatomic, retain) NSSet *beers;
@property (nonatomic, retain) Location *location;

// Holds all the beers grouped by serve types
@property NSMutableDictionary *serveTypes;

// Holds all the serve types
@property NSMutableArray *serveTypeKeys;


+ (NSManagedObjectContext *) getObjectContext;

+ (NSArray *)all;
+ (NSArray *)findAll:(NSPredicate *)predicate;
+ (Menu *)find:(NSPredicate *)predicate;

+ (Menu *)getCurrentForLocation:(NSString *)location;
+ (Menu *)getLastForLocation:(NSString *)location;

// Fetches menu from server
+ (void)fetchForLocation:(NSString *)location success:(void (^)(Menu *menu))action failedWithError:(void (^)(NSError *))errorAction;

// Fetches menu from server
+ (void)refreshForLocation:(NSString *)location success:(void (^)(Menu *menu))action failedWithError:(void (^)(NSError *))errorAction;

// Parses the menu from JSON
+ (Menu *)menuFromJSON:(NSDictionary *)results;

// Gets all beers grouped in their beer style category for a serve type
- (NSDictionary *)getBeersGrouped:(NSString *)group serveType:(NSString *)serveType sort:(NSString *)sort;

// Gets all the style categories of beer for serve type
//- (NSArray *)getBeerGroup:(NSString *)group serveType:(NSString *)serveType;

- (NSArray *)getBeerCountsForServeTypes;

- (void) flagNewBeersSinceLastMenu:(Menu *)lastMenu;

@end

@interface Menu (CoreDataGeneratedAccessors)

- (void)addBeersObject:(Beer *)value;
- (void)removeBeersObject:(Beer *)value;
- (void)addBeers:(NSSet *)values;
- (void)removeBeers:(NSSet *)values;

@end
