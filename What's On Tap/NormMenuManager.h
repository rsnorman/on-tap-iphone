//
//  NormBeersManager.h
//  What's On Tap
//
//  Created by Ryan Norman on 11/29/13.
//  Copyright (c) 2013 Ryan Norman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NormMenuManagerDelegate.h"
#import "NormWhatsOnTapDelegate.h"

//@interface NormMenuManager : NSObject

@class NormWhatsOnTap;

@interface NormMenuManager : NSObject<NormWhatsOnTapDelegate>

@property (strong, nonatomic) NormWhatsOnTap *communicator;
@property (weak, nonatomic) id<NormMenuManagerDelegate> delegate;

- (void)fetchAvailableMenuAtLocation;

@end
