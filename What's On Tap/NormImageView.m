//
//  NormImageView.m
//  On Tap
//
//  Created by Ryan Norman on 12/27/13.
//  Copyright (c) 2013 Ryan Norman. All rights reserved.
//

#import "NormImageView.h"
#import "constants.h"
#import "QuartzCore/CALayer.h"

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
        
        self.defaultImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.defaultImageView.backgroundColor = [UIColor whiteColor];
        [self.defaultImageView setContentMode:UIViewContentModeScaleAspectFit];
        [self.defaultImageView setOpaque:YES];
        [self.defaultImageView.layer setCornerRadius:imageLayer.cornerRadius];
        [self.defaultImageView.layer setBorderWidth:imageLayer.borderWidth];
        [self.defaultImageView.layer setBorderColor:imageLayer.borderColor];
        [self.defaultImageView.layer setMasksToBounds:imageLayer.masksToBounds];
        [self.defaultImageView.layer setBackgroundColor:imageLayer.backgroundColor];
        self.defaultImageView.layer.opacity = 1.0;
        
        [self addSubview:self.defaultImageView];
    }
    return self;
}

- (void)setURLForImage:(NSString *)URL defaultImage:(UIImage *)defaultImage
{
    self.URL = URL;
    [self.defaultImageView setHidden:YES];
    
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
            [self.defaultImageView setHidden:NO];
            self.defaultImageView.image = defaultImage;
            self.defaultImageView.layer.opacity = 1.0;
            
            // get the UIImage
            [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.URL]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                
                if ([response.URL.absoluteString isEqualToString:self.URL] && error == nil) {
                    [self performSelectorOnMainThread:@selector(fadeInImage:) withObject:[UIImage imageWithData:data] waitUntilDone:NO];
                } else {
                    NSLog(@"Error: %@", error);
                }
                
            }];
        }
    } else {
        self.image = defaultImage;
    }
}

- (void)fadeInImage:(UIImage *)downloadedImage
{
    self.image = downloadedImage;
    
    if (self.image.size.height / self.image.size.width > _MAX_IMAGE_RATIO) {
        [self setContentMode:UIViewContentModeScaleAspectFit];
    } else{
        [self setContentMode:UIViewContentModeScaleToFill];
    }
    
    [NormImageCache setImage:self.image forKey:self.URL];
    
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^
     {
         self.defaultImageView.layer.opacity = 0.0;
     }
                     completion:nil];
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
