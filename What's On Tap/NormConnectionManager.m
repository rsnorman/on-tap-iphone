//
//  NormConnectionNotifier.m
//  On Tap
//
//  Created by Ryan Norman on 2/8/14.
//  Copyright (c) 2014 Ryan Norman. All rights reserved.
//

#import "NormConnectionManager.h"

@implementation NormConnectionManager


- (id) init {
    self = [super init];
    
    if (self) {
        /*
         Observe the kNetworkReachabilityChangedNotification. When that notification is posted, the method reachabilityChanged will be called.
         */
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
        
        self.internetReachability = [Reachability reachabilityForInternetConnection];
        [self.internetReachability startNotifier];
    }
    
    return self;
}

/*!
 * Called by Reachability whenever status changes.
 */
- (void) reachabilityChanged:(NSNotification *)note
{
    if ([self connectedToNetwork]) {
        if ([self.delegate respondsToSelector:@selector(didConnectToNetwork)]) {
            [self.delegate didConnectToNetwork];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(didDisconnectToNetwork)]) {
            [self.delegate didDisconnectToNetwork];
        }
    }
}

- (BOOL) connectedToNetwork
{
    BOOL isInternet = NO;
    Reachability* reachability = [Reachability reachabilityWithHostName:@"google.com"];
    NetworkStatus remoteHostStatus = [reachability currentReachabilityStatus];
    
    if(remoteHostStatus == NotReachable)
    {
        isInternet = NO;
    }
    else if (remoteHostStatus == ReachableViaWWAN)
    {
        isInternet = YES;
    }
    else if (remoteHostStatus == ReachableViaWiFi)
    {
        isInternet = YES;
    }
    return isInternet;
}

@end
