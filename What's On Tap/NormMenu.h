//
//  NormMenu.h
//  What's On Tap
//
//  Created by Ryan Norman on 12/16/13.
//  Copyright (c) 2013 Ryan Norman. All rights reserved.
//

#import "NormBeer.h"
#import <Foundation/Foundation.h>

@interface NormMenu : NSObject

@property NSMutableArray *beers;

+ (NormMenu *)menuFromJSON:(NSData *)objectNotation error:(NSError **)error;

@end
