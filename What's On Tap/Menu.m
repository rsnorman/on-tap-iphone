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

@implementation Menu

@dynamic locationId;
@dynamic createdOn;
@dynamic mID;
@dynamic location;
@dynamic beers;

@synthesize serveTypeKeys;
@synthesize serveTypes;

NSMutableDictionary *beerGroups;
NSMutableDictionary *groupedBeers;
NSManagedObjectContext *managedObjectContext;

+ (NSManagedObjectContext *) getObjectContext
{
    if (managedObjectContext != nil) {
        id appDelegate = (id)[[UIApplication sharedApplication] delegate];
        managedObjectContext = [appDelegate managedObjectContext];
    }
    
    return managedObjectContext;
}

+ (NSArray *) all
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Menu" inManagedObjectContext: [Menu getObjectContext]];
    [fetchRequest setEntity:entity];

    NSError *error;
    NSArray *menus = [[self getObjectContext] executeFetchRequest:fetchRequest error:&error];
    
    return menus;
}

+ (NSArray *) findAll:(NSPredicate *)predicate
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Menu" inManagedObjectContext:[Menu getObjectContext]];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *menus = [[self getObjectContext] executeFetchRequest:fetchRequest error:&error];
    
    return menus;
}

+ (Menu *) find:(NSPredicate *)predicate
{
    return (Menu *)[[self findAll:predicate] objectAtIndex:0];
}

+ (Menu *) last:(NSPredicate *)predicate
{
    NSArray *menus = [self findAll:predicate];
    
    if ([menus count] > 0) {
        return (Menu *)[menus objectAtIndex:[menus count] - 1];
    }
    
    return nil;
}

+ (Menu *)getLastForLocation: (NSString *)location
{
    NSDateComponents *components = [[NSCalendar currentCalendar]
                                    components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit
                                    fromDate:[NSDate date]];
    NSDate *today = [[NSCalendar currentCalendar]
                     dateFromComponents:components];
    
    Menu *menu = [self last:[NSPredicate predicateWithFormat:@"locationId == %@ AND createdOn < %@", location, today]];
    
    if ( menu != nil) {
        [menu setup];
        return menu;
    } else {
        return nil;
    }
}

+ (Menu *)getCurrentForLocation: (NSString *)location
{
    NSDateComponents *components = [[NSCalendar currentCalendar]
                                    components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit
                                    fromDate:[NSDate date]];
    NSDate *today = [[NSCalendar currentCalendar]
                     dateFromComponents:components];
    
    Menu *menu = [self last:[NSPredicate predicateWithFormat:@"locationId == %@ AND createdOn >= %@", location, today]];
    
    if ( menu != nil) {
        [menu setup];
        return menu;
    } else {
        return nil;
    }
}

+ (void)fetchForLocation:(NSString *)location success:(void (^)(Menu *))action failedWithError:(void (^)(NSError *))errorAction
{
    NSString *urlAsString = [NSString stringWithFormat:@"http://whatisontap.herokuapp.com/locations/%@/menus/today", location];
    
    // Local brewery
    // NSString *urlAsString = @"http://whatisontap.herokuapp.com/locations/11580/menus/today";
    
    NSURL *url = [[NSURL alloc] initWithString:urlAsString];
    NSLog(@"Grab From: %@", urlAsString);
    
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
                                                       inManagedObjectContext:[Menu getObjectContext]];
    
    menu.mID = [results objectForKey:@"_id"];
    menu.locationId = (NSString *)[results objectForKey:@"locationId"];
    menu.location = [Location findByLocationId:menu.locationId];
    
    menu.createdOn = [NSDate date];
    [menu save];
    
    for (NSDictionary *beerDic in jsonBeers) {
        Beer *beer = [NSEntityDescription insertNewObjectForEntityForName:@"Beer"
                                                   inManagedObjectContext:[Menu getObjectContext]];
        
        beer.bID = [beerDic objectForKey:@"_id"];
        beer.menuID = menu.mID;
        beer.name = [beerDic objectForKey:@"name"];
        beer.style = [beerDic objectForKey:@"style"];
        beer.styleCategory = [beerDic objectForKey:@"styleCategory"];
        beer.abv = [beerDic objectForKey:@"abv"];
        beer.breweryLink = [beerDic objectForKey:@"breweryLink"];
        beer.breweryName = [[beerDic objectForKey:@"breweryName"] stringByTrimmingCharactersInSet:
                                                                  [NSCharacterSet whitespaceCharacterSet]];
        
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
        
        if (beer.breweryName.length == 0) {
            beer.breweryName = @"Unknown";
        }
        
        [menu addBeersObject:beer];
        
        [menu save];
    }
    
    [menu setup];

    return menu;
}

+ (Menu *) new
{
    return [NSEntityDescription insertNewObjectForEntityForName:@"Menu"
                                  inManagedObjectContext:[Menu getObjectContext]];
}

- (void) save
{
    [[Menu getObjectContext] save:nil];
}

- (void)setup
{
    self.serveTypeKeys = [[NSMutableArray alloc] init];
    self.serveTypes = [[NSMutableDictionary alloc] init];
    
    beerGroups = [[NSMutableDictionary alloc] init];
    groupedBeers = [[NSMutableDictionary alloc] init];
    
    [self.serveTypes setObject:[[NSMutableArray alloc] init] forKey:@"On Tap"];
    [self.serveTypeKeys addObject: @"On Tap"];
    
    for (Beer* beer in [self.beers allObjects])
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
}


- (NSDictionary *)getBeersGrouped:(NSString *)group serveType:(NSString *)serveType sort:(NSString *)sort
{
    beerGroups = [[NSMutableDictionary alloc] init];
    groupedBeers = [[NSMutableDictionary alloc] init];
    
    NSMutableDictionary *groupedBeersForServeType;
    
    for (NSString *serveType in serveTypeKeys) {
        NSSortDescriptor *beerSort;
        if ([sort isEqualToString:@"abv"]) {
            beerSort = [NSSortDescriptor sortDescriptorWithKey:sort
                                          ascending:NO];
        } else{
            beerSort = [NSSortDescriptor sortDescriptorWithKey:sort
                                          ascending:YES];
        }
        
        NSArray *sortDescriptors = [NSArray arrayWithObject:beerSort];
        
        [self.serveTypes setObject:[(NSArray *)[self.serveTypes objectForKey:serveType] sortedArrayUsingDescriptors:sortDescriptors] forKey:serveType];
    }
    
    if ([groupedBeers objectForKey:serveType] == nil) {
        groupedBeersForServeType = [[NSMutableDictionary alloc] init];
        
        NSArray *serveTypeBeers = [self.serveTypes objectForKey:serveType];
        
        if (![group isEqualToString:@"none"]) {
            for (Beer* beer in serveTypeBeers)
            {
                    SEL groupAttributeSelector = NSSelectorFromString(group);
                    IMP groupAttribute = [beer methodForSelector:groupAttributeSelector];
                    
                    if ([groupedBeersForServeType objectForKey:groupAttribute(beer, groupAttributeSelector)] == nil) {
                        [groupedBeersForServeType setObject:[[NSMutableArray alloc] init] forKey:groupAttribute(beer, groupAttributeSelector)];
                    }
                    
                    [[groupedBeersForServeType objectForKey:groupAttribute(beer, groupAttributeSelector)] addObject:beer];
            }
        } else {
            [groupedBeersForServeType setObject:serveTypeBeers forKey:@"None"];
        }
        
        [groupedBeers setObject:groupedBeersForServeType forKey:serveType];
        
    } else {
        groupedBeersForServeType = [groupedBeers objectForKey:serveType];
    }
    
    if (![group isEqualToString:@"none"]) {
        // Add New Beers Since Last Visit
        NSArray *serveTypeBeers = [self.serveTypes objectForKey:serveType];
        NSArray *newBeersForServeType = [serveTypeBeers filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.isNew == %hhd", YES]];
        [groupedBeersForServeType setObject:newBeersForServeType forKey:@"New"];
    }
    
    return groupedBeersForServeType;
}


- (NSArray *)getBeerCountsForServeTypes
{
    NSMutableArray *beerCounts = [[NSMutableArray alloc] init];
    for (NSString* serveType in self.serveTypeKeys)
    {
        NSDictionary *beers = [self.serveTypes objectForKey:serveType];
        [beerCounts addObject:[NSNumber numberWithInteger:beers.count]];
    }
    
    return beerCounts;
}

- (void)flagNewBeersSinceLastMenu:(Menu *)lastMenu
{
    NSArray *newBeers = [NSArray arrayWithArray:[self.beers allObjects]];
    NSArray *oldBeers = [NSArray arrayWithArray:[lastMenu.beers allObjects]];
    
    
    NSMutableArray *oldBeerNames = [[NSMutableArray alloc] init];
    
    for (Beer *beer in oldBeers) {
        [oldBeerNames addObject:beer.name];
    }
    
    
    for (Beer *beer in newBeers) {
        if ([oldBeerNames filteredArrayUsingPredicate:[NSPredicate
                                                  predicateWithFormat:@"self == %@", beer.name]].count == 0 ) {
            [beer setIsNew:YES];
        }
    }
}

@end
