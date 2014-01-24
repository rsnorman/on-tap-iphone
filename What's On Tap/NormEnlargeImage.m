//
//  NormEnlargeImage.m
//  On Tap
//
//  Created by Ryan Norman on 1/14/14.
//  Copyright (c) 2014 Ryan Norman. All rights reserved.
//

#import "NormEnlargeImage.h"
#import "NormImageModalController.h"
#import "NormImageModalTransitionDelegate.h"

@implementation UIView (EnlargeImage)

NSString *_largeImageUrl;
UIViewController *_enlargeDelegate;

- (void) setDelegate:(UIViewController *)enlargeDelegate
{
    _enlargeDelegate = enlargeDelegate;
}

- (void) setLargeImageURL:(NSString *)largeImageURL
{
    _largeImageUrl = largeImageURL;
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetected)];
    singleTap.numberOfTapsRequired = 1;
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:singleTap];
}

- (void)showLargeLogo:(UIImage *)largeImage
{
    NormImageModalController *imageModalController = [[NormImageModalController alloc] init];
    [imageModalController setDraggableImage: largeImage];
    
    NormImageModalTransitionDelegate *transitionController = [[NormImageModalTransitionDelegate alloc] init];
    [transitionController setTransitionImage:largeImage];
    
    CGPoint imagePosition = [_enlargeDelegate.view convertPoint:self.frame.origin toView:nil];
    CGRect windowFrame = self.window.screen.bounds;
    
    [transitionController setStartFrame: CGRectMake(imagePosition.x, imagePosition.y, self.frame.size.width, self.frame.size.height)];
    
    float imageWidth = largeImage.size.width;
    float imageHeight = largeImage.size.height;
    
    if (imageWidth > windowFrame.size.width) {
        imageHeight = imageHeight * windowFrame.size.width / imageWidth;
        imageWidth = windowFrame.size.width;
    }
    
    if (imageHeight > windowFrame.size.height) {
        imageWidth = imageWidth * windowFrame.size.height / imageHeight;
        imageHeight = windowFrame.size.height;
    }
    
    [transitionController setFinishFrame:CGRectMake((windowFrame.size.width - imageWidth) / 2, (windowFrame.size.height - imageHeight) / 2, imageWidth, imageHeight)];
    
    [transitionController setDuration: 0.25f];
    [transitionController setZoomOutPercentage:0.85f];
    [transitionController setStartLayer:self.layer];
    CALayer *finishLayer = [[CALayer alloc] init];
    [finishLayer setCornerRadius:5.0];
    [finishLayer setMasksToBounds:YES];
    [transitionController setFinishLayer:finishLayer];
    
    
    [imageModalController setTransitioningDelegate:transitionController];
    _enlargeDelegate.modalPresentationStyle = UIModalPresentationCustom;
    [_enlargeDelegate presentViewController:imageModalController animated:YES completion:nil];
}

-(void)tapDetected{
    
    
    if (_largeImageUrl.length != 0) {
        UIActivityIndicatorView *imageDownloadProgress = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        imageDownloadProgress.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
        [imageDownloadProgress startAnimating];
        [imageDownloadProgress setHidesWhenStopped:YES];
        [self addSubview:imageDownloadProgress];
        
        [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_largeImageUrl]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            
            [imageDownloadProgress removeFromSuperview];
            [self setNeedsDisplay];
            
            [self performSelector:@selector(showLargeLogo:) withObject:[UIImage imageWithData:data] afterDelay:0.01];
        }];
    }
}

@end
