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

@property NormBeer *beer;
@property NormImageCache *imageCache;

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *breweryLabel;
@property (nonatomic, weak) IBOutlet UILabel *styleLabel;
@property (nonatomic, weak) IBOutlet UILabel *abvLabel;
@property (nonatomic, weak) IBOutlet UIImageView *logoImage;
@property (nonatomic, weak) IBOutlet UITextView *descriptionText;

@end
