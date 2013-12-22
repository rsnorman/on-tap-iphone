//
//  NormMenuManagerDelegate.h
//  What's On Tap
//
//  Created by Ryan Norman on 11/29/13.
//  Copyright (c) 2013 Ryan Norman. All rights reserved.
//
#import "NormMenu.h"
#import <Foundation/Foundation.h>

@protocol NormMenuManagerDelegate <NSObject>
- (void)didReceiveMenu:(NormMenu *)menu;
- (void)fetchingMenuFailedWithError:(NSError *)error;
@end
