//
//  NormImageModalController.h
//  On Tap
//
//  Created by Ryan Norman on 1/9/14.
//  Copyright (c) 2014 Ryan Norman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NormImageModalController : UIViewController

//@property UIScrollView *scrollView;
@property UIImage *draggableImage;
@property BOOL imageZoomedIn;

- (UIImageView *) getPresentedImage;

@end
