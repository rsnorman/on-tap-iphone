//
//  AnimatedTransitioning.m
//  CustomTransitionExample
//
//  Created by Blanche Faur on 10/24/13.
//  Copyright (c) 2013 Blanche Faur. All rights reserved.
//

#import "NormModalShowTransitioning.h"
#import "NormViewSnapshot.h"

@implementation NormModalShowTransitioning

float zoomOutPaddingX;
float zoomOutPaddingY;

UIImage *bgImage;
UIImage *bgBlurredImage;
UIImageView *bgImageView;
UIImageView *bgBlurredImageView;
UIView *borderView;


- (id) initWithFromController:(UIViewController *)fromVC toController:(UIViewController <NormModalControllerDelegate> *)toVC
{
    self = [super init];
    if (self) {
        [self setToVC:toVC];
        [self setFromVC:fromVC];
        self.duration = 0.25f;
        self.zoomOutPercentage = 0.95;
    }
    
    return self;
}

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return self.duration;
}


- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    
    self.animationView = [transitionContext containerView];
    
    if (self.isPresenting){
        [self willAnimateShowTransition];
        
        [UIView animateWithDuration:self.duration
                         animations:^{
                             [self addShowAnimations];
                         }
                         completion:^(BOOL finished) {
                             [self didAnimateShowTransition];
                             [transitionContext completeTransition:YES];
                         }];
    } else {
        [self willAnimateHideTransition];
        
        [UIView animateWithDuration:self.duration
                         animations:^{
                             [self addHideAnimations];
                         }
                         completion:^(BOOL finished) {
                             [self didAnimateHideTransition];
                             [transitionContext completeTransition:YES];
                         }];
    }
}

- (void) willAnimateShowTransition
{

    bgImage = [NormViewSnapshot snapshotOfView:self.fromVC.view];
    bgBlurredImage = [NormViewSnapshot blurredSnapshotOfView:self.fromVC.view];
    
    zoomOutPaddingX = (bgImage.size.width - (bgImage.size.width * self.zoomOutPercentage)) / 2;
    zoomOutPaddingY = (bgImage.size.height - (bgImage.size.height * self.zoomOutPercentage)) / 2;
    
    bgImageView = [[UIImageView alloc] initWithImage:bgImage];
    bgBlurredImageView = [[UIImageView alloc] initWithImage:bgBlurredImage];
    
    [bgImageView setFrame:CGRectMake(zoomOutPaddingX, zoomOutPaddingY, bgImage.size.width, bgImage.size.height)];
    [bgBlurredImageView setFrame:CGRectMake(zoomOutPaddingX, zoomOutPaddingY, bgImage.size.width, bgImage.size.height)];
    
    borderView = [[UIView alloc] initWithFrame:CGRectMake(zoomOutPaddingX * -1, zoomOutPaddingY * -1, bgImage.size.width + (zoomOutPaddingX * 2), bgImage.size.height + (zoomOutPaddingY * 2))];
    [borderView setBackgroundColor:[UIColor blackColor]];
    
    [borderView addSubview:bgBlurredImageView];
    [borderView addSubview:bgImageView];
    
    [self.animationView addSubview:self.toVC.view];
    [self.animationView addSubview:borderView];
}

- (void) addShowAnimations
{
    bgImageView.alpha = 0.0f;
    [borderView setFrame:CGRectMake(0, 0, self.animationView.window.frame.size.width, self.animationView.window.frame.size.height)];
    [bgImageView setFrame:CGRectMake(zoomOutPaddingX, zoomOutPaddingY, bgImageView.frame.size.width - (zoomOutPaddingX * 2), bgImageView.frame.size.height - (zoomOutPaddingY * 2))];
    [bgBlurredImageView setFrame:CGRectMake(zoomOutPaddingX, zoomOutPaddingY, bgBlurredImageView.frame.size.width - (zoomOutPaddingX * 2), bgBlurredImageView.frame.size.height - (zoomOutPaddingY * 2))];
}

- (void) didAnimateShowTransition
{
    
    UIImage *zoomedOutBg = [NormViewSnapshot snapshotOfView:borderView];
    
    UIImageView *zoomedOutBgView = [[UIImageView alloc] initWithImage:zoomedOutBg];
    
    [self.toVC.view addSubview:zoomedOutBgView];
    [self.toVC.view sendSubviewToBack:zoomedOutBgView];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self.toVC action:@selector(modalShouldBeDismissed)];
    
    singleTap.numberOfTapsRequired = 1;
    zoomedOutBgView.userInteractionEnabled = YES;
    [zoomedOutBgView addGestureRecognizer:singleTap];
}

- (void) willAnimateHideTransition
{    
    bgImageView = [[UIImageView alloc] initWithImage:bgImage];
    bgBlurredImageView = [[UIImageView alloc] initWithImage:bgBlurredImage];
    
    bgImageView.frame = CGRectMake(zoomOutPaddingX, zoomOutPaddingY, bgImage.size.width - (zoomOutPaddingX * 2), bgImage.size.height - (zoomOutPaddingY * 2));
    
    bgBlurredImageView.frame = CGRectMake(zoomOutPaddingX, zoomOutPaddingY, bgImage.size.width - (zoomOutPaddingX * 2), bgImage.size.height - (zoomOutPaddingY * 2));
    
    borderView = [[UIView alloc] initWithFrame:self.toVC.view.frame];
    [borderView setBackgroundColor:[UIColor blackColor]];
    [borderView addSubview:bgImageView];
    [borderView addSubview:bgBlurredImageView];
    
    [self.animationView addSubview:borderView];
}

- (void) addHideAnimations
{
    bgBlurredImageView.alpha = 0.0f;
    [borderView setFrame:CGRectMake(zoomOutPaddingX * -1, zoomOutPaddingY * -1, self.animationView.window.frame.size.width + (zoomOutPaddingX * 2), self.animationView.window.frame.size.height + zoomOutPaddingY * 2)];
    [bgImageView setFrame:CGRectOffset(self.toVC.view.frame, zoomOutPaddingX, zoomOutPaddingY)];
    [bgBlurredImageView setFrame:CGRectOffset(self.toVC.view.frame, zoomOutPaddingX, zoomOutPaddingY)];
}

- (void) didAnimateHideTransition
{
    
}

@end