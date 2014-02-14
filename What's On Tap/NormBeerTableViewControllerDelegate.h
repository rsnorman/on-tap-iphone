//
//  NormBeerTableViewControllerDelegate.h
//  On Tap
//
//  Created by Ryan Norman on 2/10/14.
//  Copyright (c) 2014 Ryan Norman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Beer.h"

@protocol NormBeerTableViewControllerDelegate <NSObject>

@optional
-(void) didSelectBeer:(Beer *)beer;
@end
