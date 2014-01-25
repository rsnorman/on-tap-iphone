//
//  NormLocation.m
//  On Tap
//
//  Created by Ryan Norman on 1/14/14.
//  Copyright (c) 2014 Ryan Norman. All rights reserved.
//

#import "NormLocation.h"

@implementation NormLocation

+ (void)fetch:(void (^)(NSArray *))action failedWithError:(void (^)(NSError *))errorAction
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
        NormLocation *location = [[NormLocation alloc] init];
        
        location.lID = [locationDic objectForKey:@"locationId"];
        location.name = [locationDic objectForKey:@"name"];
        location.address = [locationDic objectForKey:@"address"];
        location.type = [locationDic objectForKey:@"type"];
        
        [locations addObject:location];
    }
    
    return locations;
}

@end
