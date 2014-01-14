//
//  NormBeerViewController.m
//  What's On Tap
//
//  Created by Ryan Norman on 12/2/13.
//  Copyright (c) 2013 Ryan Norman. All rights reserved.
//

#import "NormBeerViewController.h"
#import "NormImageCache.h"
#import "NormDraggableImageViewDelegate.h"
#import "NormModalTransitionDelegate.h"
#import "NormImageModalTransitionDelegate.h"
#import "NormImageModalController.h"
#import "NormModalControllerDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreImage/CoreImage.h>

@interface NormBeerViewController ()
@property NormBeer *beer;

@end

@implementation NormBeerViewController

@synthesize nameLabel = _nameLabel;
@synthesize breweryLabel = _breweryLabel;
@synthesize styleLabel = _styleLabel;
@synthesize abvLabel = _abvLabel;
@synthesize logoImage = _logoImage;
@synthesize descriptionText = _descriptionText;
@synthesize beer = _beer;


- (id)init{
    self = [super init];
    
    if (self){
        
        float imageWidth = 90.0;
        float imageHeight = 90.0;
        float topPadding = 15.0;
        float windowWidth = self.view.frame.size.width;
        
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, windowWidth, self.view.frame.size.height)];
        scrollView.showsHorizontalScrollIndicator = YES;
        [self.view addSubview:scrollView];
        
        self.logoImage = [[NormImageView alloc] initWithFrame:CGRectMake(5.0, topPadding, imageWidth, imageHeight)];
        [self.logoImage setBorderWidth:2];
        [self.logoImage setBorderColor:[UIColor whiteColor]];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetected)];
        singleTap.numberOfTapsRequired = 1;
        self.logoImage.userInteractionEnabled = YES;
        [self.logoImage addGestureRecognizer:singleTap];
        
        [scrollView addSubview:self.logoImage];
        
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(imageWidth + 20, topPadding, windowWidth - imageWidth - 25.0, 20)];
        self.nameLabel.font = [UIFont boldSystemFontOfSize:18.0];
        [self.nameLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [self.nameLabel setNumberOfLines:0];
        self.nameLabel.textColor = [UIColor whiteColor];
        [scrollView addSubview:self.nameLabel];
        
        self.breweryLabel = [[UILabel alloc] initWithFrame:CGRectMake(imageWidth + 20, topPadding + 20, windowWidth - imageWidth - 25.0, 20)];
        self.breweryLabel.font = [UIFont boldSystemFontOfSize:15.0];
        [self.breweryLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [self.breweryLabel setNumberOfLines:0];
        self.breweryLabel.textColor = [UIColor lightTextColor];
        [scrollView addSubview:self.breweryLabel];
        
        int cellHeight = 25;
        UIView *topBorder = [[UIView alloc] initWithFrame:CGRectMake(0, imageHeight + topPadding + 10, windowWidth, 1)];
        topBorder.backgroundColor = [UIColor darkGrayColor];
        [scrollView addSubview:topBorder];
        
        UIView *middleBorder = [[UIView alloc] initWithFrame:CGRectMake(0, imageHeight + topPadding + cellHeight + 10, windowWidth, 1)];
        middleBorder.backgroundColor = [UIColor darkGrayColor];
        [scrollView addSubview:middleBorder];
        
        UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, imageHeight + topPadding + 10 + (cellHeight * 2), windowWidth, 1)];
        bottomBorder.backgroundColor = [UIColor darkGrayColor];
        [scrollView addSubview:bottomBorder];
        
        UIView *verticalBorder = [[UIView alloc] initWithFrame:CGRectMake(windowWidth / 2.0, imageHeight + topPadding + 10, 1, cellHeight * 2)];
        verticalBorder.backgroundColor = [UIColor darkGrayColor];
        [scrollView addSubview:verticalBorder];
        
        self.styleLabel = [[UILabel alloc] init];
        [self addCellLabel:self.styleLabel frame:CGRectMake(0, imageHeight + topPadding + 10, windowWidth / 2, cellHeight)];
        [scrollView addSubview:self.styleLabel];
        
        self.servedInLabel = [[UILabel alloc] init];
        [self addCellLabel:self.servedInLabel frame:CGRectMake(windowWidth / 2, imageHeight + topPadding + 10, windowWidth / 2, cellHeight)];
        [scrollView addSubview:self.servedInLabel];
        
        self.abvLabel = [[UILabel alloc] init];
        [self addCellLabel:self.abvLabel frame:CGRectMake(0, imageHeight + topPadding + cellHeight + 10, windowWidth / 2, cellHeight)];
        [scrollView addSubview:self.abvLabel];
        
        self.costLabel = [[UILabel alloc] init];
        [self addCellLabel:self.costLabel frame:CGRectMake(windowWidth / 2, imageHeight + topPadding + cellHeight + 10, windowWidth / 2, cellHeight)];
        [scrollView addSubview:self.costLabel];
        
        self.descriptionText = [[UITextView alloc] initWithFrame:CGRectMake(5, imageHeight + topPadding + 10 + cellHeight * 2, windowWidth - 10, 300)];
        self.descriptionText.backgroundColor = [UIColor clearColor];
        self.descriptionText.textColor = [UIColor lightTextColor];
        self.descriptionText.font = [UIFont systemFontOfSize:14];
        self.descriptionText.textAlignment = NSTextAlignmentJustified;
        self.descriptionText.scrollEnabled = NO;
        [self.descriptionText setEditable:NO];

        [scrollView addSubview:self.descriptionText];
        

        
    }
    
    return self;
}

- (void)showLargeLogo:(UIImage *)largeLogo
{
    NormImageModalController *imageModalController = [[NormImageModalController alloc] init];
    [imageModalController setDraggableImage: largeLogo];
    
    
    NormImageModalTransitionDelegate *transitionController = [[NormImageModalTransitionDelegate alloc] init];
    [transitionController setTransitionImage:largeLogo];
    
    CGPoint logoPosition = [self.view convertPoint:self.logoImage.frame.origin toView:nil];
    CGRect windowFrame = self.view.window.screen.bounds;
    
    [transitionController setStartFrame: CGRectMake(logoPosition.x, logoPosition.y, self.logoImage.frame.size.width, self.logoImage.frame.size.height)];
    
    float logoWidth = largeLogo.size.width;
    float logoHeight = largeLogo.size.height;
    
    if (logoWidth > windowFrame.size.width) {
        logoHeight = logoHeight * windowFrame.size.width / logoWidth;
        logoWidth = windowFrame.size.width;
    }
    
    if (logoHeight > windowFrame.size.height) {
        logoWidth = logoWidth * windowFrame.size.height / logoHeight;
        logoHeight = windowFrame.size.height;
    }
    
    [transitionController setFinishFrame:CGRectMake((windowFrame.size.width - logoWidth) / 2, (windowFrame.size.height - logoHeight) / 2, logoWidth, logoHeight)];
    
    [transitionController setDuration: 0.25f];
    [transitionController setZoomOutPercentage:0.92f];
    [transitionController setStartLayer:self.logoImage.layer];
    CALayer *finishLayer = [[CALayer alloc] init];
    [finishLayer setCornerRadius:5.0];
    [finishLayer setMasksToBounds:YES];
    [transitionController setFinishLayer:finishLayer];
    
    
    [imageModalController setTransitioningDelegate:transitionController];
    self.modalPresentationStyle = UIModalPresentationCustom;
    [self presentViewController:imageModalController animated:YES completion:nil];
}

-(void)tapDetected{
    
    
    UIActivityIndicatorView *imageDownloadProgress = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    imageDownloadProgress.center = CGPointMake(self.logoImage.frame.size.width / 2, self.logoImage.frame.size.height / 2);
    [imageDownloadProgress startAnimating];
    [imageDownloadProgress setHidesWhenStopped:YES];
    [self.logoImage addSubview:imageDownloadProgress];
    
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[self.beer.label objectForKey:@"url"]]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        [imageDownloadProgress removeFromSuperview];
        [self.logoImage setNeedsDisplay];
        
        [self performSelector:@selector(showLargeLogo:) withObject:[UIImage imageWithData:data] afterDelay:0.01];
    }];
}


// Creates a label meant for the grid
- (void)addCellLabel:(UILabel *)label frame:(CGRect)frame
{
    label.frame = frame;
    label.font = [UIFont systemFontOfSize:12.0];
    label.textColor = [UIColor lightGrayColor];
    label.textAlignment = NSTextAlignmentCenter;
    [label setLineBreakMode:NSLineBreakByTruncatingTail];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.nameLabel setText:self.beer.name];
    [self.breweryLabel setText:self.beer.breweryName];
    [self.styleLabel setText:self.beer.style];
    [self.abvLabel setText:[NSString stringWithFormat:@"ABV: %g%%", self.beer.abv]];
    [self.descriptionText setText:self.beer.description];
    [self.servedInLabel setText:self.beer.servedIn];
    [self.costLabel setText: [NSString stringWithFormat:@"$%.02f", self.beer.price]];
    
    CGSize nameSize = [self.nameLabel sizeThatFits:CGSizeMake(self.nameLabel.frame.size.width, CGFLOAT_MAX)];
    CGSize brewerySize = [self.breweryLabel sizeThatFits:CGSizeMake(self.breweryLabel.frame.size.width, CGFLOAT_MAX)];
    
    self.nameLabel.frame = CGRectMake(self.nameLabel.frame.origin.x, (90 - (nameSize.height + brewerySize.height + 2)) / 2 + 15, self.nameLabel.frame.size.width, nameSize.height);
    self.breweryLabel.frame = CGRectMake(self.nameLabel.frame.origin.x, self.nameLabel.frame.origin.y + nameSize.height + 5, self.breweryLabel.frame.size.width, brewerySize.height);
    
    CGSize descriptionSize = [self.descriptionText sizeThatFits:CGSizeMake(self.descriptionText.frame.size.width, CGFLOAT_MAX)];
    self.descriptionText.frame = CGRectMake(self.descriptionText.frame.origin.x, self.descriptionText.frame.origin.y, self.descriptionText.frame.size.width, descriptionSize.height);
    
    UIScrollView * scrollView = [self.view.subviews objectAtIndex:0];
    scrollView.contentSize = CGSizeMake(self.view.frame.size.width, descriptionSize.height + 190);
    
    [self.logoImage setURLForImage:[[self.beer.label objectForKey:@"thumbnail"] objectForKey:@"url"] defaultImage: [UIImage imageNamed: [self.beer.serveType isEqual: @"Bottles"] ? @"bottle.png" : [self.beer.serveType isEqual: @"Bottles"] ? @"can.png" : @"glass.png"]];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    [self.view setBackgroundColor:_DARK_COLOR];

    self.title = @"Details";
    self.navigationItem.title = @"Details";
    
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
