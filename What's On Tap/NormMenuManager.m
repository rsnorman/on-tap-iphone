//
//  NormMenuManager.m
//  What's On Tap
//
//  Created by Ryan Norman on 11/29/13.
//  Copyright (c) 2013 Ryan Norman. All rights reserved.
//

#import "NormMenuManager.h"
#import "NormMenu.h"
#import "NormWhatsOnTap.h"

@implementation NormMenuManager

- (void)fetchAvailableMenuAtLocation
{
    [self.communicator fetchAvailableMenuAtLocation];
}

- (void)receivedMenuJSON:(NSData *)objectNotation
{
    NSError *error = nil;
//    NormMenu *menu = [NormMenu menuFromJSON:objectNotation error:&error];
    
    if (error != nil) {
        [self.delegate fetchingMenuFailedWithError:error];
        
    } else {
//        [self.delegate didReceiveMenu:menu];
    }
}

- (void)fetchingMenuFailedWithError:(NSError *)error
{
    [self.delegate fetchingMenuFailedWithError:error];
}

@end
