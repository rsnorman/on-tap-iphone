//
//  Menu.m
//  On Tap
//
//  Created by Ryan Norman on 1/25/14.
//  Copyright (c) 2014 Ryan Norman. All rights reserved.
//

#import "Menu.h"
#import "Beer.h"
#import "Location.h"
#import "NormBeer.h"


@implementation Menu

@dynamic locationId;
@dynamic createdOn;
@dynamic mID;
@dynamic location;
@dynamic beers;

@synthesize serveTypeKeys;
@synthesize serveTypes;

NSMutableDictionary *beerStyles;
NSMutableDictionary *groupedBeers;
NSManagedObjectContext *managedObjectContext;

+ (void)fetchForLocation:(NSString *)location success:(void (^)(Menu *))action failedWithError:(void (^)(NSError *))errorAction
{
    id appDelegate = (id)[[UIApplication sharedApplication] delegate];
    managedObjectContext = [appDelegate managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Menu" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSDateComponents *components = [[NSCalendar currentCalendar]
                                    components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit
                                    fromDate:[NSDate date]];
    NSDate *today = [[NSCalendar currentCalendar]
                         dateFromComponents:components];
    
//    NSDate *tomorrow = [NSDate dateWithTimeIntervalSinceNow: (60.0f*60.0f*24.0f)]; // For Test whether it refreshes correctly
    
    NSPredicate *predicateID = [NSPredicate predicateWithFormat:@"locationId == %@ AND createdOn >= %@", location, today];
    [fetchRequest setPredicate:predicateID];
    
    NSError *error;
    
    NSArray *menus = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if ( [menus count] > 0) {
        Menu * menu = [menus objectAtIndex:[menus count] - 1];
        [menu setup];
        NSLog(@"Grabbed Menu From DB, created on: %@", menu.createdOn);
        action(menu);
    } else {
        NSString *urlAsString = [NSString stringWithFormat:@"http://whatisontap.herokuapp.com/locations/%@/menus/today", location];
        
        // Local brewery
//        NSString *urlAsString = @"http://whatisontap.herokuapp.com/locations/11580/menus/today";
        
        NSURL *url = [[NSURL alloc] initWithString:urlAsString];
        NSLog(@"Grab From: %@", urlAsString);
        
        [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:url] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            
            if (error) {
                errorAction(error);
            } else {                
                NSError *localError = nil;
                NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:1 error:&localError];
                
                NSLog(@"%@", results);
                
                if (localError != nil) {
                    errorAction(localError);
                    
                    return;
                }
                
                action([self menuFromJSON:results]);
            }
        }];
    }
}

+ (void)refreshForLocation:(NSString *)location success:(void (^)(Menu *))action failedWithError:(void (^)(NSError *))errorAction
{
    NSString *urlAsString;
    urlAsString = [NSString stringWithFormat:@"http://whatisontap.herokuapp.com/locations/%@/menus/today?refresh=true", location];
    
    
    NSURL *url = [[NSURL alloc] initWithString:urlAsString];
    NSLog(@"%@", urlAsString);
    
    [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:url] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (error) {
            errorAction(error);
        } else {
            NSError *localError = nil;
            NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:1 error:&localError];
            
            if (localError != nil) {
                errorAction(localError);
                
                return;
            }
            
            action([self menuFromJSON:results]);
        }
    }];
}

+ (Menu *)menuFromJSON:(NSDictionary *)results
{
    
    
    NSArray *jsonBeers = [results objectForKey:@"beers"];
    
    Menu *menu = [NSEntityDescription insertNewObjectForEntityForName:@"Menu"
                                                       inManagedObjectContext:managedObjectContext];
    
    menu.mID = [results objectForKey:@"_id"];
    menu.locationId = (NSString *)[results objectForKey:@"locationId"];
    menu.location = [Location findByLocationId:menu.locationId];
    
    menu.createdOn = [NSDate date];
    [managedObjectContext save:nil];
    
    for (NSDictionary *beerDic in jsonBeers) {
        Beer *beer = [NSEntityDescription insertNewObjectForEntityForName:@"Beer"
                                                   inManagedObjectContext:managedObjectContext];
        
        beer.bID = [beerDic objectForKey:@"_id"];
        beer.menuID = menu.mID;
        beer.name = [beerDic objectForKey:@"name"];
        beer.style = [beerDic objectForKey:@"style"];
        beer.styleCategory = [beerDic objectForKey:@"styleCategory"];
        beer.abv = [beerDic objectForKey:@"abv"];
        beer.breweryLink = [beerDic objectForKey:@"breweryLink"];
        beer.breweryName = [beerDic objectForKey:@"breweryName"];
        
        @try
        {
            beer.price = [beerDic objectForKey:@"price"];
        }
        @catch(NSException* ex)
        {
            beer.price = nil;
        }
        
        beer.summary = [beerDic objectForKey:@"description"];
        beer.servedIn = [beerDic objectForKey:@"servedIn"];
        beer.serveType = [beerDic objectForKey:@"serveType"];
        beer.label = [[beerDic objectForKey:@"label"] objectForKey:@"url"];
        beer.thumbnailLabel = [[[beerDic objectForKey:@"label"] objectForKey:@"thumbnail"] objectForKey:@"url"];
        beer.menu = menu;
        
        // Add special style if none found
        if (beer.style.length == 0) {
            beer.style = @"Special";
        }

        // Add special category if none found
        if (beer.styleCategory.length == 0) {
            beer.styleCategory = @"Special";
        }
        
        [menu addBeersObject:beer];
        
        [managedObjectContext save:nil];
    }
    
    [menu setup];

    return menu;
}

- (void)setup
{
    self.serveTypeKeys = [[NSMutableArray alloc] init];
    self.serveTypes = [[NSMutableDictionary alloc] init];
    
    beerStyles = [[NSMutableDictionary alloc] init];
    groupedBeers = [[NSMutableDictionary alloc] init];
    
    [self.serveTypes setObject:[[NSMutableArray alloc] init] forKey:@"On Tap"];
    [self.serveTypeKeys addObject: @"On Tap"];
    
    for (NormBeer* beer in [self.beers allObjects])
    {
        
        if ([self.serveTypes objectForKey:beer.serveType] == nil){
            [self.serveTypes setObject:[[NSMutableArray alloc] init] forKey:beer.serveType];
            [self.serveTypeKeys addObject: beer.serveType];
        }
        
        [[self.serveTypes objectForKey:beer.serveType] addObject:beer];
    }
    
    if ([[self.serveTypes objectForKey:@"On Tap"] count] == 0) {
        [self.serveTypeKeys removeObject:@"On Tap"];
    }
    
    for (NSString *serveType in serveTypeKeys) {
        NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"name"
                                                                     ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortByName];
        
        [self.serveTypes setObject:[(NSArray *)[self.serveTypes objectForKey:serveType] sortedArrayUsingDescriptors:sortDescriptors] forKey:serveType];
    }
}


- (NSDictionary *)getBeersGroupedByStyleForServeType:(NSString *)serveType
{
    NSMutableDictionary *groupedBeersForServeType;
    
    if ([groupedBeers objectForKey:serveType] == nil) {
        groupedBeersForServeType = [[NSMutableDictionary alloc] init];
        
        NSArray *serveTypeBeers = [self.serveTypes objectForKey:serveType];
        
        for (NormBeer* beer in serveTypeBeers)
        {
            if ([groupedBeersForServeType objectForKey:beer.styleCategory] == nil) {
                [groupedBeersForServeType setObject:[[NSMutableArray alloc] init] forKey:beer.styleCategory];
            }
            
            [[groupedBeersForServeType objectForKey:beer.styleCategory] addObject:beer];
        }
        
        [groupedBeers setObject:groupedBeersForServeType forKey:serveType];
        
    } else {
        groupedBeersForServeType = [groupedBeers objectForKey:serveType];
    }
    
    return groupedBeersForServeType;
}

- (NSArray *)getBeerStylesForServeType:(NSString *)serveType
{
    NSArray *orderedBeerStyles;
    
    if ([beerStyles objectForKey:serveType] == nil) {
        NSMutableArray * unOrderedStyleKeys = [[NSMutableArray alloc] init];
        
        for (NormBeer* beer in [self.serveTypes objectForKey:serveType])
        {
            if (![unOrderedStyleKeys containsObject:beer.styleCategory]){
                [unOrderedStyleKeys addObject:beer.styleCategory];
            }
            
        }
        
        orderedBeerStyles = [unOrderedStyleKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        
        [beerStyles setObject:orderedBeerStyles forKey:serveType];
    } else {
        orderedBeerStyles = [beerStyles objectForKey:serveType];
    }
    
    return orderedBeerStyles;
}

@end
