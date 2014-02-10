//
//  NormConnectionNotifierDelegate.h
//  On Tap
//
//  Created by Ryan Norman on 2/8/14.
//  Copyright (c) 2014 Ryan Norman. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NormConnectionManagerDelegate <NSObject>

@optional
- (void) didConnectToNetwork;
- (void) didDisconnectToNetwork;
@end
