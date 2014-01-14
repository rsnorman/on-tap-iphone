
//
//  NormModalController.h
//  On Tap
//
//  Created by Ryan Norman on 1/13/14.
//  Copyright (c) 2014 Ryan Norman. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NormModalControllerDelegate <NSObject>

- (void) modalShouldBeDismissed;
@end
