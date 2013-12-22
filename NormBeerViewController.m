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
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _imageCache = [[NormImageCache alloc] init];
    
	// Do any additional setup after loading the view.
    UIColor *backgroundColor = [UIColor colorWithRed:42.0/255.0 green:39.0/255.0 blue:46.0/255.0 alpha:1.0];
    
    [self.view setBackgroundColor:backgroundColor];
    [self.descriptionText setBackgroundColor:backgroundColor];
    [self.nameLabel setText:self.beer.name];
    [self.breweryLabel setText:self.beer.breweryName];
    [self.styleLabel setText:self.beer.style];
    [self.abvLabel setText:[NSString stringWithFormat:@"ABV: %g%%", self.beer.abv]];
    [self.descriptionText setText:self.beer.description];
    
    [self.nameLabel sizeToFit];
    [self.breweryLabel sizeToFit];
    [self.styleLabel sizeToFit];
    [self.descriptionText setText:self.beer.description];
    
    CALayer *imageLayer = self.logoImage.layer;
    [imageLayer setCornerRadius:35];
    [imageLayer setBorderWidth:3];
    [imageLayer setBorderColor:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0].CGColor];
    [imageLayer setMasksToBounds:YES];
    
//    if (self.beer.label.length != 0){
//        [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.beer.label]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
//            self.logoImage.image = [UIImage imageWithData:data];
//        }];
//    } else {
//        if ([self.beer.serveType  isEqual: @"On Tap"]) {
//            [self.logoImage setImage:[UIImage imageNamed: @"tap-highlight.png"]];
//        } else if ([self.beer.serveType  isEqual: @"Bottles"]) {
//            [self.logoImage setImage:[UIImage imageNamed: @"bottle-highlight.png"]];
//        } else {
//            [self.logoImage setImage:[UIImage imageNamed: @"can-highlight.png"]];
//        }
//    }
    
    if (_beer.label.length != 0){
        
        UIImage *image = [self.imageCache imageForKey:_beer.label];
        
        if (image)
        {
            NSLog(@"Grabbed from cache");
            [self.logoImage setImage: image];
        }
        else {
            NSLog(@"Couldn't find in cache");
            if ([_beer.serveType  isEqual: @"On Tap"]) {
                [self.logoImage setImage:[UIImage imageNamed: @"tap-highlight.png"]];
            } else if ([_beer.serveType  isEqual: @"Bottles"]) {
                [self.logoImage setImage:[UIImage imageNamed: @"bottle-highlight.png"]];
            } else {
                [self.logoImage setImage:[UIImage imageNamed: @"can-highlight.png"]];
            }
            
            // get the UIImage
            [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_beer.label]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                UIImage *image = [UIImage imageWithData:data];
                [self.logoImage setImage: image];
                [self.imageCache setImage:image forKey:_beer.label];
            }];
        }
    } else {
        if ([_beer.serveType  isEqual: @"On Tap"]) {
            [self.logoImage setImage:[UIImage imageNamed: @"tap-highlight.png"]];
        } else if ([_beer.serveType  isEqual: @"Bottles"]) {
            [self.logoImage setImage:[UIImage imageNamed: @"bottle-highlight.png"]];
        } else {
            [self.logoImage setImage:[UIImage imageNamed: @"can-highlight.png"]];
        }
    }
    
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
