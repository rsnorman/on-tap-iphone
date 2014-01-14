//
//  NormBeerViewController.h
//  What's On Tap
//
//  Created by Ryan Norman on 12/2/13.
//  Copyright (c) 2013 Ryan Norman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NormBeer.h"
#import "NormImageView.h"
#import "NormDraggableImageView.h"
#import "constants.h"

// View controller for deatils of an individual beer
@interface NormBeerViewController : UIViewController

// Label for the name of the beer
@property UILabel *nameLabel;

// Label for the name of the brewery that makes the beer
@property UILabel *breweryLabel;

// Label for the style of the beer
@property UILabel *styleLabel;

// Label for the alcohol by volume for the beer
@property UILabel *abvLabel;

// Image view for the label/logo of the beer
@property NormImageView *logoImage;

// Text view for the description of the beer
@property UITextView *descriptionText;

// Label for the served in label for the beer
@property UILabel *servedInLabel;

// Label for the cost of the beer
@property UILabel *costLabel;

@property UIView *overlay;

// Sets the active beer for the controller
-(void)setBeer:(NormBeer *)beer;

// Shows the large version of the beer logo/label
//- (void)showLargeLogo:(UIImage *)largeLogo;

@end
