//
//  NormImageView.m
//  On Tap
//
//  Created by Ryan Norman on 12/27/13.
//  Copyright (c) 2013 Ryan Norman. All rights reserved.
//

#import "NormImageView.h"

@implementation NormImageView

@synthesize scaleToFillAspectRatioMax = _scaleToFillAspectRatioMax;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self setContentMode:UIViewContentModeScaleAspectFit];
        [self setScaleToFillAspectRatioMax: 1.5];
        [self setOpaque:YES];
        
        CALayer *imageLayer = self.layer;
        [imageLayer setCornerRadius:MAX(frame.size.height, frame.size.width) / 2];
        [imageLayer setBorderWidth:1];
        [imageLayer setBorderColor:[UIColor colorWithRed:201.0/255.0 green:201.0/255.0 blue:201.0/255.0 alpha:1.0].CGColor];
        [imageLayer setMasksToBounds:YES];
        [imageLayer setBackgroundColor:[UIColor whiteColor].CGColor];
    }
    return self;
}

- (void)setURLForImage:(NSString *)URL defaultImage:(UIImage *)defaultImage
{
    NormImageCache *imageCache = [[NormImageCache alloc] init];
    if (URL.length != 0){
        
        UIImage *image = [imageCache imageForKey:URL];
        
        if (image) {
            self.image = image;
            
            if (image.size.height / image.size.width > self.scaleToFillAspectRatioMax) {
                [self setContentMode:UIViewContentModeScaleAspectFit];
            } else{
                [self setContentMode:UIViewContentModeScaleToFill];
            }
        }
        else {
            self.image = defaultImage;
            
            // get the UIImage
            [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:URL]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                
                self.image = [UIImage imageWithData:data];
                
                if (image.size.height / image.size.width > self.scaleToFillAspectRatioMax) {
                    [self setContentMode:UIViewContentModeScaleAspectFit];
                } else{
                    [self setContentMode:UIViewContentModeScaleToFill];
                }
                
                [imageCache setImage:self.image forKey:URL];
            }];
        }
    } else {
        self.image = defaultImage;
    }
}

- (void)setBorderColor:(UIColor *)color
{
    [self.layer setBorderColor:color.CGColor];
}

- (void)setBorderWidth:(CGFloat)width
{
    [self.layer setBorderWidth:width];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor{
    // Do Nothing
}

@end
