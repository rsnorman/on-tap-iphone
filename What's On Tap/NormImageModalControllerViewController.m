//
//  NormImageModalControllerViewController.m
//  On Tap
//
//  Created by Ryan Norman on 1/9/14.
//  Copyright (c) 2014 Ryan Norman. All rights reserved.
//

#import "NormDraggableImageView.h"
#import "NormImageModalControllerViewController.h"
#import "NormBlurImage.h"

@interface NormImageModalControllerViewController () <NormDraggableImageViewDelegate>

@end

@implementation NormImageModalControllerViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	
    float height = self.draggableImage.size.height;
    float width = self.draggableImage.size.width;
    NormDraggableImageView *draggableImageView = [[NormDraggableImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - width) / 2, (self.view.frame.size.height - height) / 2, width, height)];
    [draggableImageView setImage:self.draggableImage];
    [self.view setFrame:draggableImageView.frame];
    
    [draggableImageView setDelegate: self];
    [self.view addSubview:draggableImageView];
    
    UIImage *bgBlurredImage = [self blurredSnapshotOfView:[self presentingViewController].view];
    UIImageView *modalBlurredImageView = [[UIImageView alloc] initWithImage:bgBlurredImage];
    
    [self.view addSubview:modalBlurredImageView];
    [self.view sendSubviewToBack:modalBlurredImageView];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageShouldBeDismissed)];
    
    singleTap.numberOfTapsRequired = 1;
    modalBlurredImageView.userInteractionEnabled = YES;
    [modalBlurredImageView addGestureRecognizer:singleTap];
}

- (void)imageShouldBeDismissed
{
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (void)imageShouldBeThrownOffScreen:(NormDraggableImageView *)imageView
{
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

-(UIImage *)blurredSnapshotOfView:(UIView *)view
{
    // Create the image context
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, view.window.screen.scale);
    
    // There he is! The new API method
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:NO];
    
    // Get the snapshot
    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // Now apply the blur effect using Apple's UIImageEffect category
    //    UIImage *blurredSnapshotImage = [snapshotImage applyLightEffect];
    
    // Or apply any other effects available in "UIImage+ImageEffects.h"
    UIImage *blurredSnapshotImage = [snapshotImage applyDarkEffect];
    // UIImage *blurredSnapshotImage = [snapshotImage applyExtraLightEffect];
    
    // Be nice and clean your mess up
    UIGraphicsEndImageContext();
    
    return blurredSnapshotImage;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
