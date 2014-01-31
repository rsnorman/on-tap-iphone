//
//  NormIndicatorView.h
//  On Tap
//
//  Created by Ryan Norman on 1/30/14.
//  Copyright (c) 2014 Ryan Norman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NormIndicatorView : UIView

@property UIActivityIndicatorView *spinner;
@property UILabel *messageLabel;
@property BOOL hidesWhenStopped;

-(void) setMessage:(NSString *)message;
-(void) startAnimating;
-(void) stopAnimating;
-(void) setHidesWhenStopped:(BOOL)hidesWhenStopped;
@end
