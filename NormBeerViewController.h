//
//  NormBeerViewController.h
//  What's On Tap
//
//  Created by Ryan Norman on 12/2/13.
//  Copyright (c) 2013 Ryan Norman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NormBeer.h"
#import "NormImageCache.h"

@interface NormBeerViewController : UIViewController


@property UILabel *nameLabel;
@property UILabel *breweryLabel;
@property UILabel *styleLabel;
@property UILabel *abvLabel;
@property UIImageView *logoImage;
@property UITextView *descriptionText;
@property UILabel *servedInLabel;
@property UILabel *costLabel;

-(void)setBeer:(NormBeer *)beer;

@end
