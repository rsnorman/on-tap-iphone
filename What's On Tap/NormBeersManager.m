//
//  NormBeersManager.m
//  What's On Tap
//
//  Created by Ryan Norman on 11/29/13.
//  Copyright (c) 2013 Ryan Norman. All rights reserved.
//

#import "NormBeersManager.h"
#import "NormBeer.h"
#import "NormWhatsOnTap.h"

@implementation NormBeersManager

- (void)fetchAvailableBeersAtLocation
{
    [self.communicator fetchAvailableBeersAtLocation];
}

- (void)receivedBeersJSON:(NSData *)objectNotation
{
    NSError *error = nil;
    NSArray *beers = [NormBeer beersFromJSON:objectNotation error:&error];
    
    if (error != nil) {
        [self.delegate fetchingBeersFailedWithError:error];
        
    } else {
        [self.delegate didReceiveBeers:beers];
    }
}

- (void)fetchingBeersFailedWithError:(NSError *)error
{
    [self.delegate fetchingBeersFailedWithError:error];
}

@end
