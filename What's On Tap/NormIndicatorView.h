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
- (void)setErrorMessage:(NSString *)errorMessage;
-(void) startAnimating;
-(void) stopAnimating;
-(void) stopAnimatingWithSuccessMessage:(NSString *) successMessage withDelay:(float) delay;
- (void)stopAnimatingWithSuccessMessage:(NSString *)successMessage withDelay:(float)delay hide:(void (^)(BOOL isComplete))hide;
-(void) setHidesWhenStopped:(BOOL)hidesWhenStopped;
@end
