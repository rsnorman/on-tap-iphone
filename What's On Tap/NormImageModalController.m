//
//  NormImageModalControllerViewController.m
//  On Tap
//
//  Created by Ryan Norman on 1/9/14.
//  Copyright (c) 2014 Ryan Norman. All rights reserved.
//

#import "NormDraggableImageView.h"
#import "NormImageModalController.h"
#import "NormBlurImage.h"
#import "NormModalControllerDelegate.h"

@interface NormImageModalController () <NormDraggableImageViewDelegate, NormModalControllerDelegate>

@end

@implementation NormImageModalController

NormDraggableImageView *draggableImageView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    float width = self.draggableImage.size.width;
    float height = self.draggableImage.size.height;
    
    if (width > self.view.frame.size.width) {
        height = height * self.view.frame.size.width / width;
        width = self.view.frame.size.width;
    }
    
    if (height > self.view.frame.size.height) {
        width = width * self.view.frame.size.height / height;
        height = self.view.frame.size.height;
    }
    
    draggableImageView = [[NormDraggableImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - width) / 2, (self.view.frame.size.height - height) / 2, width, height)];
    [draggableImageView setImage:self.draggableImage];
    [self.view setFrame:draggableImageView.frame];
    
    [draggableImageView setDelegate: self];
    [self.view addSubview:draggableImageView];
}

- (UIImageView *)getPresentedImage{
    return draggableImageView;
}

- (void)modalShouldBeDismissed
{
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (void)imageShouldBeThrownOffScreen:(NormDraggableImageView *)imageView
{
    [self modalShouldBeDismissed];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
