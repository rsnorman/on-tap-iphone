//
//  NormBeer.m
//  What's On Tap
//
//  Created by Ryan Norman on 11/28/13.
//  Copyright (c) 2013 Ryan Norman. All rights reserved.
//

#import "NormBeer.h"

@implementation NormBeer

+ (NSArray *)beersFromJSON:(NSData *)objectNotation error:(NSError **)error
{
    NSError *localError = nil;
    NSArray *results = [NSJSONSerialization JSONObjectWithData:objectNotation options:1 error:&localError];
    
    if (localError != nil) {
        *error = localError;
        return nil;
    }
    
    NSMutableArray *beers = [[NSMutableArray alloc] init];
    
//    NSArray *results = [parsedObject valueForKey:@"results"];
    NSLog(@"Count %d", results.count);
    
    for (NSDictionary *beerDic in results) {
        NormBeer *beer = [[NormBeer alloc] init];
        
        for (NSString *key in beerDic) {
            if ([beer respondsToSelector:NSSelectorFromString(key)]) {
                [beer setValue:[beerDic valueForKey:key] forKey:key];
            }
        }
        
        [beers addObject:beer];
    }
    
    return beers;
}

- (id)init
{
    self = [super init];
    
    if (self) {
    }
    
    return self;
}

@end
