//
//  NormBeerViewController.m
//  What's On Tap
//
//  Created by Ryan Norman on 12/2/13.
//  Copyright (c) 2013 Ryan Norman. All rights reserved.
//

#import "NormBeerViewController.h"
#import <QuartzCore/QuartzCore.h>

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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    
    return self;
}


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
        
        self.logoImage = [[UIImageView alloc] initWithFrame:CGRectMake(5.0, topPadding, imageWidth, imageHeight)];
        self.logoImage.backgroundColor = [UIColor whiteColor];
        CALayer *imageLayer = self.logoImage.layer;
        [imageLayer setCornerRadius:45];
        [imageLayer setBorderWidth:2];
        [imageLayer setBorderColor:[UIColor whiteColor].CGColor];
        [imageLayer setMasksToBounds:YES];
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
    
    NSLog(@"Beer: %@", self.beer);
    
    NormImageCache *imageCache = [[NormImageCache alloc] init];
    
    
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
    
    if (_beer.label.length != 0){
        
        UIImage *image = [imageCache imageForKey:self.beer.label];
        
        if (image)
        {
            [self.logoImage setImage: image];
        }
        else {
            if ([_beer.serveType  isEqual: @"On Tap"]) {
                [self.logoImage setImage:[UIImage imageNamed: @"glass.png"]];
            } else if ([_beer.serveType  isEqual: @"Bottles"]) {
                [self.logoImage setImage:[UIImage imageNamed: @"glass.png"]];
//                [self.logoImage setImage:[UIImage imageNamed: @"bottle-highlight.png"]];
            } else {
                [self.logoImage setImage:[UIImage imageNamed: @"glass.png"]];
//                [self.logoImage setImage:[UIImage imageNamed: @"can-highlight.png"]];
            }
            
            // get the UIImage
            [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_beer.label]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                UIImage *image = [UIImage imageWithData:data];
                [self.logoImage setImage: image];
                [imageCache setImage:image forKey:_beer.label];
            }];
        }
    } else {
        if ([_beer.serveType  isEqual: @"On Tap"]) {
            [self.logoImage setImage:[UIImage imageNamed: @"glass.png"]];
        } else if ([_beer.serveType  isEqual: @"Bottles"]) {
            [self.logoImage setImage:[UIImage imageNamed: @"bottle-highlight.png"]];
        } else {
            [self.logoImage setImage:[UIImage imageNamed: @"can-highlight.png"]];
        }
    }

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    UIColor *backgroundColor = [UIColor colorWithRed:42.0/255.0 green:39.0/255.0 blue:46.0/255.0 alpha:1.0];
    
    [self.view setBackgroundColor:backgroundColor];

    
//    [self.nameLabel sizeToFit];
//    [self.breweryLabel sizeToFit];
//    [self.styleLabel sizeToFit];
//    [self.descriptionText setText:self.beer.description];
    
    self.title = @"Details"; //self.beer.name; // TabBarItem.title inherits the viewController's self.title
    self.navigationItem.title = @"Details"; //self.beer.name;
    self.navigationItem.backBarButtonItem.title = @"list";

    
    NSArray *ver = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    if ([[ver objectAtIndex:0] intValue] >= 7) {
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
        self.navigationController.navigationBar.translucent = YES;
    }else {
        self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
