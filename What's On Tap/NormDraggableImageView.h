//
//  NormDraggableImageView.h
//  On Tap
//
//  Created by Ryan Norman on 1/3/14.
//  Copyright (c) 2014 Ryan Norman. All rights reserved.
//

#import "NormDraggableImageViewDelegate.h"
#import <UIKit/UIKit.h>

@interface NormDraggableImageView : UIImageView
@property CGPoint previousPoint;
@property NSDate *lastTouchAt;
@property BOOL zoomedIn;
@property BOOL aspectRatio;
@property(nonatomic,assign) id<NormDraggableImageViewDelegate> delegate;
@end
