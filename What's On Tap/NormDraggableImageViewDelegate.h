//
//  NormDraggableImageViewDelegate.h
//  On Tap
//
//  Created by Ryan Norman on 1/7/14.
//  Copyright (c) 2014 Ryan Norman. All rights reserved.
//

@class NormDraggableImageView;
#import <Foundation/Foundation.h>

@protocol NormDraggableImageViewDelegate <NSObject>

- (void)imageShouldBeThrownOffScreen:(NormDraggableImageView *)imageView;

@end
