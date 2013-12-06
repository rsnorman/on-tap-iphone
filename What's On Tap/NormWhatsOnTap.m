//
//  NormWhatsOnTap.m
//  What's On Tap
//
//  Created by Ryan Norman on 11/29/13.
//  Copyright (c) 2013 Ryan Norman. All rights reserved.
//

#import "NormWhatsOnTap.h"

@implementation NormWhatsOnTap

-(void) fetchAvailableBeersAtLocation
{
//    NSString *urlAsString = @"http://localhost:5000/beers";
    NSString *urlAsString = @"http://whatisontap.herokuapp.com/beers";
    NSURL *url = [[NSURL alloc] initWithString:urlAsString];
    NSLog(@"%@", urlAsString);

    [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:url] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (error) {
            [self.delegate fetchingBeersFailedWithError:error];
        } else {
            [self.delegate receivedBeersJSON:data];
        }
    }];
}

@end
