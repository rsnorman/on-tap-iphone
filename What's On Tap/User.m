//
//  User.m
//  On Tap
//
//  Created by Ryan Norman on 1/28/14.
//  Copyright (c) 2014 Ryan Norman. All rights reserved.
//

#import "User.h"
#import "Location.h"


@implementation User

@dynamic name;
@dynamic currentLocation;

NSManagedObjectContext *managedObjectContext;


+(User *) current
{
    NSError *error;
    id appDelegate = (id)[[UIApplication sharedApplication] delegate];
    managedObjectContext = [appDelegate managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User"
                                              inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    return [fetchedObjects objectAtIndex:0];
}

- (void)save
{
    [managedObjectContext save:nil];
}
@end
