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


@end

@implementation NormBeerViewController

@synthesize nameLabel = _nameLabel;
@synthesize breweryLabel = _breweryLabel;
@synthesize styleLabel = _styleLabel;
@synthesize abvLabel = _abvLabel;
@synthesize logoImage = _logoImage;
@synthesize descriptionText = _descriptionText;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.nameLabel setText:self.beer.name];
    [self.breweryLabel setText:self.beer.breweryName];
    [self.styleLabel setText:self.beer.style];
    [self.abvLabel setText:[NSString stringWithFormat:@"ABV: %g %%", self.beer.abv]];
    [self.descriptionText setText:self.beer.description];
    
    [self.nameLabel sizeToFit];
    [self.breweryLabel sizeToFit];
    
//    [self.descriptionText setScrollEnabled:YES];
    [self.descriptionText setText:self.beer.description];
//    [self.descriptionText sizeToFit];
//    [self.descriptionText setScrollEnabled:NO];
    
    CALayer *imageLayer = self.logoImage.layer;
    [imageLayer setCornerRadius:35];
    [imageLayer setBorderWidth:1];
    [imageLayer setBorderColor:[UIColor colorWithRed:201.0/255.0 green:201.0/255.0 blue:201.0/255.0 alpha:1.0].CGColor];
    [imageLayer setMasksToBounds:YES];
    
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.beer.label]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        self.logoImage.image = [UIImage imageWithData:data];
    }];
    
    self.title = self.beer.name; // TabBarItem.title inherits the viewController's self.title
    self.navigationItem.title = self.beer.name;
    self.navigationItem.backBarButtonItem.title = @"list";
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
