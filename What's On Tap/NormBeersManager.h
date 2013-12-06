//
//  NormBeersManager.h
//  What's On Tap
//
//  Created by Ryan Norman on 11/29/13.
//  Copyright (c) 2013 Ryan Norman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NormBeersManagerDelegate.h"
#import "NormWhatsOnTapDelegate.h"

//@interface NormBeersManager : NSObject

@class NormWhatsOnTap;

@interface NormBeersManager : NSObject<NormWhatsOnTapDelegate>

@property (strong, nonatomic) NormWhatsOnTap *communicator;
@property (weak, nonatomic) id<NormBeersManagerDelegate> delegate;

- (void)fetchAvailableBeersAtLocation;

@end
