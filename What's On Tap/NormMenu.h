//
//  NormMenu.h
//  What's On Tap
//
//  Created by Ryan Norman on 12/16/13.
//  Copyright (c) 2013 Ryan Norman. All rights reserved.
//

#import "NormBeer.h"
#import <Foundation/Foundation.h>

// Model for the menu that holds all the beers
@interface NormMenu : NSObject

// All the beers in the menu
@property NSArray *beers;

 // Filter string for searching menu
@property NSString *filter;

// Holds all the beers grouped by serve types
@property NSMutableDictionary *serveTypes;

// Holds all the serve types
@property NSMutableArray *serveTypeKeys;

// Fetches menu from server
+ (void)fetch:(void (^)(NormMenu *menu))action failedWithError:(void (^)(NSError *))errorAction;

// Parses the menu from JSON
+ (NormMenu *)menuFromJSON:(NSData *)objectNotation;

// Gets all beers grouped in their beer style category for a serve type
- (NSDictionary *)getBeersGroupedByStyleForServeType:(NSString *)serveType;

// Gets all the style categories of beer for serve type
- (NSArray *)getBeerStylesForServeType:(NSString *)serveType;

// Adds a filter to the menu
- (void)applyFilter:(NSString *)filter;

// Removes the filter from the menu
- (void)removeFilter;


@end
