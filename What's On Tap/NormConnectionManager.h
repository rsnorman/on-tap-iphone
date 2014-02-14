//
//  NormConnectionNotifier.h
//  On Tap
//
//  Created by Ryan Norman on 2/8/14.
//  Copyright (c) 2014 Ryan Norman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"
#import "NormConnectionManagerDelegate.h"

@interface NormConnectionManager : NSObject

@property (nonatomic) Reachability *internetReachability;
@property (nonatomic) id<NormConnectionManagerDelegate> delegate;
@property BOOL isConnectedToInternet;
@property BOOL isCheckingConnection;

- (void) checkForConnection;
- (BOOL) isConnected;

@end
