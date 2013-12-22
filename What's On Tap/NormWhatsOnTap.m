//
//  NormWhatsOnTap.m
//  What's On Tap
//
//  Created by Ryan Norman on 11/29/13.
//  Copyright (c) 2013 Ryan Norman. All rights reserved.
//

#import "NormWhatsOnTap.h"

@implementation NormWhatsOnTap

-(void) fetchAvailableMenuAtLocation
{
//    NSString *urlAsString = @"http://localhost:3000/menus/today";
    NSString *urlAsString = @"http://whatisontap.herokuapp.com/menus/today";
    NSURL *url = [[NSURL alloc] initWithString:urlAsString];
    NSLog(@"%@", urlAsString);

    [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:url] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (error) {
            [self.delegate fetchingMenuFailedWithError:error];
        } else {
            [self.delegate receivedMenuJSON:data];
        }
    }];
}

@end
