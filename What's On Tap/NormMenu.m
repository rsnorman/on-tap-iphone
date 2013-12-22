//
//  NormMenu.m
//  What's On Tap
//
//  Created by Ryan Norman on 12/16/13.
//  Copyright (c) 2013 Ryan Norman. All rights reserved.
//

#import "NormMenu.h"

@implementation NormMenu

+ (NormMenu *)menuFromJSON:(NSData *)objectNotation error:(NSError **)error
{
    NSError *localError = nil;
    NSDictionary *results = [NSJSONSerialization JSONObjectWithData:objectNotation options:1 error:&localError];
    
    if (localError != nil) {
        *error = localError;
        return nil;
    }
    
    NormMenu *menu = [[NormMenu alloc] init];
    
    menu.beers = [[NSMutableArray alloc] init];
    
    //    NSArray *results = [parsedObject valueForKey:@"results"];
    NSArray *jsonBeers = [results objectForKey:@"beers"];
    NSLog(@"Beer Count: %d unique beers", jsonBeers.count);
    
    for (NSDictionary *beerDic in jsonBeers) {
        NormBeer *beer = [[NormBeer alloc] init];
        
        for (NSString *key in beerDic) {
            if ([beer respondsToSelector:NSSelectorFromString(key)]) {
                [beer setValue:[beerDic valueForKey:key] forKey:key];
            }
        }
        
        if (beer.style.length == 0) {
            beer.style = @"Special";
        }
        
        if (beer.styleCategory.length == 0) {
            beer.styleCategory = @"Special";
        }
        
        [menu.beers addObject:beer];
    }
    
    return menu;
}

@end
