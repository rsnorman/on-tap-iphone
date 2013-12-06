//
//  NormBeer.h
//  What's On Tap
//
//  Created by Ryan Norman on 11/28/13.
//  Copyright (c) 2013 Ryan Norman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NormBeer : NSObject

@property NSString *_id;
@property NSString *name;
@property NSString *serveType;
@property NSString *servedIn;
@property float abv;
@property float price;
@property NSString *breweryName;
@property NSString *breweryLink;
@property NSString *link;
@property NSString *style;
@property NSString *lastUpdatedAt;
@property NSString *label;
@property NSString *description;

+ (NSArray *)beersFromJSON:(NSData *)objectNotation error:(NSError **)error;

@end
