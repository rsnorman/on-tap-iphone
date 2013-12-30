//
//  NormImageView.h
//  On Tap
//
//  Created by Ryan Norman on 12/27/13.
//  Copyright (c) 2013 Ryan Norman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NormImageCache.h"

// Image view for displaying images using a URL. Default image is displayed until image is downloaded
// from URL. Once image has been downloaded once NormImageCache is used to store image so it
// will not need to be downloaded again.
@interface NormImageView : UIImageView

// The max aspect ratio allowed for scaling the image to fit completely in the view
// Once max is passed content mode UIViewContentModeScaleToFill is used
@property float scaleToFillAspectRatioMax;

// Sets the URL for this image view while supplying a default image to use while image is downloaded or
// if image cannot be found
- (void) setURLForImage:(NSString *)URL defaultImage:(UIImage *)defaultImage;

// Sets the border color of the image view
- (void) setBorderColor:(UIColor *)color;

// Sets the border width of the image view
- (void) setBorderWidth:(CGFloat)width;
@end
