//
//  Location.m
//  On Tap
//
//  Created by Ryan Norman on 1/25/14.
//  Copyright (c) 2014 Ryan Norman. All rights reserved.
//

#import "Location.h"
#import "Menu.h"


@implementation Location

@dynamic name;
@dynamic address;
@dynamic type;
@dynamic lID;
@dynamic menus;

NSManagedObjectContext *managedObjectContext;

+ (NSArray *)fetch
{
    id appDelegate = (id)[[UIApplication sharedApplication] delegate];
    managedObjectContext = [appDelegate managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Location" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *error;
    return [managedObjectContext executeFetchRequest:fetchRequest error:&error];
}

+ (void)fetchFromServer:(void (^)(NSArray *))action failedWithError:(void (^)(NSError *))errorAction
{
    NSString *urlAsString = @"http://whatisontap.herokuapp.com/locations";
    NSURL *url = [[NSURL alloc] initWithString:urlAsString];
    NSLog(@"%@", urlAsString);
    
    [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:url] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (error) {
            errorAction(error);
        } else {
            action([self locationsFromJSON:data]);
        }
    }];
}

+ (NSArray *)locationsFromJSON:(NSData *)objectNotation
{
    NSError *localError = nil;
    NSArray *results = [NSJSONSerialization JSONObjectWithData:objectNotation options:1 error:&localError];
    
    if (localError != nil) {
        //        *error = localError;
        return nil;
    }
    
    NSMutableArray *locations = [[NSMutableArray alloc] init];
    NSArray *locationsJSON = results;
    
    for(NSDictionary *locationDic in locationsJSON) {
        Location *location = [NSEntityDescription insertNewObjectForEntityForName:@"Location"
                                      inManagedObjectContext:managedObjectContext];
        
        location.lID = [locationDic objectForKey:@"locationId"];
        location.name = (NSString *)[locationDic objectForKey:@"name"];
        location.address = [locationDic objectForKey:@"address"];
        location.type = [locationDic objectForKey:@"type"];
        
        [locations addObject:location];
        [managedObjectContext save:nil];
    }
    
    return locations;
}

+ (Location *)findByLocationId:(NSString *)locationId
{
    id appDelegate = (id)[[UIApplication sharedApplication] delegate];
    managedObjectContext = [appDelegate managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Location" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    NSPredicate *predicateID = [NSPredicate predicateWithFormat:@"lID == %@", locationId];
    [fetchRequest setPredicate:predicateID];
    
    NSError *error;
    return [[managedObjectContext executeFetchRequest:fetchRequest error:&error] objectAtIndex:0];
}

@end
