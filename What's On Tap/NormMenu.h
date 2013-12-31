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
@property NSMutableDictionary *styles;
@property NSArray *styleKeys;
@property NSMutableDictionary *serveTypes;
@property NSMutableArray *serveTypeKeys;
@property NSString *filter;

// Parses the menu from JSON
+ (void)fetch:(void (^)(NormMenu *menu))action;
+ (NormMenu *)menuFromJSON:(NSData *)objectNotation;
- (NSDictionary *)getBeersGroupedByStyleForServeType:(NSString *)serveType;
- (NSArray *)getBeerStylesForServeType:(NSString *)serveType;
- (void)applyFilter:(NSString *)filter;
- (void)removeFilter;
@end
