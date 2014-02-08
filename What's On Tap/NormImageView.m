//
//  NormImageView.m
//  On Tap
//
//  Created by Ryan Norman on 12/27/13.
//  Copyright (c) 2013 Ryan Norman. All rights reserved.
//

#import "NormImageView.h"
#import "constants.h"

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
    self.URL = URL;
    self.defaultImage = defaultImage;
    
    if (self.URL.length != 0){
        
        UIImage *image = [NormImageCache imageForKey:self.URL];
        
        if (image) {
            self.image = image;
            
            if (image.size.height / image.size.width > _MAX_IMAGE_RATIO) {
                [self setContentMode:UIViewContentModeScaleAspectFit];
            } else{
                [self setContentMode:UIViewContentModeScaleToFill];
            }
        }
        else {
            self.image = defaultImage;
            
            // get the UIImage
            [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.URL]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                
                if ([response.URL.absoluteString isEqualToString:self.URL] && error == nil) {
                    self.image = [UIImage imageWithData:data];
                    
                    if (image.size.height / image.size.width > _MAX_IMAGE_RATIO) {
                        [self setContentMode:UIViewContentModeScaleAspectFit];
                    } else{
                        [self setContentMode:UIViewContentModeScaleToFill];
                    }
                    
                    [NormImageCache setImage:self.image forKey:self.URL];
                } else {
                    NSLog(@"Error: %@", error);
                }
            }];
        }
    } else {
        self.image = self.defaultImage;
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

// Override background color so selected cell doesn't change color
- (void)setBackgroundColor:(UIColor *)backgroundColor{
    // Do Nothing
}

@end
