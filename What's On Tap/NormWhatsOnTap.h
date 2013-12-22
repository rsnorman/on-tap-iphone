//
//  NormWhatsOnTap.h
//  What's On Tap
//
//  Created by Ryan Norman on 11/29/13.
//  Copyright (c) 2013 Ryan Norman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NormWhatsOnTapDelegate.h"

@protocol NormWhatsOnTapDelegate;

@interface NormWhatsOnTap : NSObject

@property (weak, nonatomic) id<NormWhatsOnTapDelegate> delegate;

- (void)fetchAvailableMenuAtLocation;

@end
