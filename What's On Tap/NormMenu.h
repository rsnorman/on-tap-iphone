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
@property NSMutableArray *beers;

// Parses the menu from JSON
+ (NormMenu *)menuFromJSON:(NSData *)objectNotation error:(NSError **)error;

@end
