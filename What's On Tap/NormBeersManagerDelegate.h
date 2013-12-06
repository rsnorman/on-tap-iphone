//
//  NormBeersManagerDelegate.h
//  What's On Tap
//
//  Created by Ryan Norman on 11/29/13.
//  Copyright (c) 2013 Ryan Norman. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NormBeersManagerDelegate <NSObject>
- (void)didReceiveBeers:(NSArray *)beers;
- (void)fetchingBeersFailedWithError:(NSError *)error;
@end
