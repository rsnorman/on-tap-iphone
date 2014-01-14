//
//  NormBeer.h
//  What's On Tap
//
//  Created by Ryan Norman on 11/28/13.
//  Copyright (c) 2013 Ryan Norman. All rights reserved.
//

#import <Foundation/Foundation.h>

// Model for beer
@interface NormBeer : NSObject

// ID of the beer
@property NSString *_id;

// Name of the beer
@property NSString *name;

// How the beer is served
@property NSString *serveType;

// What the beer is served in
@property NSString *servedIn;

// The alcohol by volume of the beer
@property float abv;

// The price of the beer
@property float price;

// The name of the brewery that makes the beer
@property NSString *breweryName;

// URL to the brewer's webiste
@property NSString *breweryLink;

// URL to the beer
@property NSString *link;

// Style of the beer
@property NSString *style;

// Broad style of the beer
@property NSString *styleCategory;

// When the beer was last updated
@property NSString *lastUpdatedAt;

// URL to the label of the beer
@property NSDictionary *label;

// Description of the beer
@property NSString *description;

@end
