//
//  NormMenu.m
//  What's On Tap
//
//  Created by Ryan Norman on 12/16/13.
//  Copyright (c) 2013 Ryan Norman. All rights reserved.
//

#import "NormMenu.h"

@implementation NormMenu

NSMutableDictionary *beerStyles;
NSMutableDictionary *groupedBeers;

+ (void)fetch:(void (^)(NormMenu *))action failedWithError:(void (^)(NSError *))errorAction
{
    NSString *urlAsString = @"http://whatisontap.herokuapp.com/menus/today";
    NSURL *url = [[NSURL alloc] initWithString:urlAsString];
    NSLog(@"%@", urlAsString);
    
    [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:url] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (error) {
            errorAction(error);
        } else {
            action([self menuFromJSON:data]);
        }
    }];
}

+ (NormMenu *)menuFromJSON:(NSData *)objectNotation
{
    NSError *localError = nil;
    NSDictionary *results = [NSJSONSerialization JSONObjectWithData:objectNotation options:1 error:&localError];
    
    if (localError != nil) {
//        *error = localError;
        return nil;
    }
    
    NSMutableArray *beers = [[NSMutableArray alloc] init];
    NSArray *jsonBeers = [results objectForKey:@"beers"];

    
    for (NSDictionary *beerDic in jsonBeers) {
        NormBeer *beer = [[NormBeer alloc] init];
        
        for (NSString *key in beerDic) {
            if ([beer respondsToSelector:NSSelectorFromString(key)]) {
                [beer setValue:[beerDic valueForKey:key] forKey:key];
            }
        }
        
        // Add special style if none found
        if (beer.style.length == 0) {
            beer.style = @"Special";
        }
        
        // Add special category is none found
        if (beer.styleCategory.length == 0) {
            beer.styleCategory = @"Special";
        }
        
        [beers addObject:beer];
    }
    
    
    return [[NormMenu alloc] initWithBeers: beers];
}

- (id)initWithBeers:(NSArray *)beers
{
    self.beers = beers;
    self.serveTypeKeys = [[NSMutableArray alloc] init];
    self.serveTypes = [[NSMutableDictionary alloc] init];
    
    beerStyles = [[NSMutableDictionary alloc] init];
    groupedBeers = [[NSMutableDictionary alloc] init];
    
    for (NormBeer* beer in self.beers)
    {

        if ([self.serveTypes objectForKey:beer.serveType] == nil){
            [self.serveTypes setObject:[[NSMutableArray alloc] init] forKey:beer.serveType];
            [self.serveTypeKeys addObject: beer.serveType];
        }
        
        
        [[self.serveTypes objectForKey:beer.serveType] addObject:beer];
    }
    
    return self;
}


- (NSDictionary *)getBeersGroupedByStyleForServeType:(NSString *)serveType
{
    
    if ([groupedBeers objectForKey:serveType] == nil) {
        NSMutableDictionary *groupedBeersForServeType = [[NSMutableDictionary alloc] init];
        
        NSArray *serveTypeBeers = [self.serveTypes objectForKey:serveType];
        
        for (NormBeer* beer in serveTypeBeers)
        {
            if (self.filter == nil || self.filter.length == 0 || [beer.name rangeOfString:self.filter].location != NSNotFound ) {
                if ([groupedBeersForServeType objectForKey:beer.styleCategory] == nil){
                    [groupedBeersForServeType setObject:[[NSMutableArray alloc] init] forKey:beer.styleCategory];
                }
                
                [[groupedBeersForServeType objectForKey:beer.styleCategory] addObject:beer];
            }
            
        }
        
        [groupedBeers setObject:groupedBeersForServeType forKey:serveType];
        
        NSLog(@"Grouped beers");
    }

    
    return [groupedBeers objectForKey:serveType];
}

- (NSArray *)getBeerStylesForServeType:(NSString *)serveType
{
    if ([beerStyles objectForKey:serveType] == nil) {
        NSMutableArray * unOrderedStyleKeys = [[NSMutableArray alloc] init];
        
        for (NormBeer* beer in [self.serveTypes objectForKey:serveType])
        {
            if (self.filter == nil || self.filter.length == 0 || [beer.name rangeOfString:self.filter].location != NSNotFound ) {
                if (![unOrderedStyleKeys containsObject:beer.styleCategory]){
                    [unOrderedStyleKeys addObject:beer.styleCategory];
                }
            }
            
        }
        
        NSArray *sortedStyles = [unOrderedStyleKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        
        [beerStyles setObject:sortedStyles forKey:serveType];
    }
    
    return [beerStyles objectForKey:serveType];
}

- (void)applyFilter:(NSString *)filter
{
    self.filter = filter;
}

- (void)removeFilter
{
    self.filter = nil;
}


@end
