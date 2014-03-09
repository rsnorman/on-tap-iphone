//
//  NormSearchBar.m
//  On Tap
//
//  Created by Ryan Norman on 2/22/14.
//  Copyright (c) 2014 Ryan Norman. All rights reserved.
//

#import "NormSearchBar.h"
#import "constants.h"

@interface NormSearchBar () <UITextFieldDelegate>

@property UILabel *placeholderLabel;
@property UIButton *closeButton;
@property (nonatomic, retain, readonly) UIView *rightView;
@property BOOL isEditing;

@end

@implementation NormSearchBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.isEditing = NO;
        self.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0];
        
        _searchBarTextField = [[UITextField alloc] initWithFrame:CGRectMake(8, 8, frame.size.width - 16, frame.size.height - 16)];
        [_searchBarTextField setBackgroundColor:[UIColor whiteColor]];
        [_searchBarTextField.layer setCornerRadius:5.0];
        [_searchBarTextField setDelegate:self];
        [_searchBarTextField addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
        [_searchBarTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        [_searchBarTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
        UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
        _searchBarTextField.leftView = paddingView;
        _searchBarTextField.leftViewMode = UITextFieldViewModeAlways;
        [_searchBarTextField setFont:[UIFont systemFontOfSize:13.0]];
        [_searchBarTextField setTintColor:_MAIN_COLOR];
        [self addSubview:_searchBarTextField];
        
        _placeholderLabel = [[UILabel alloc] initWithFrame:_searchBarTextField.frame];
        [_placeholderLabel setTextAlignment:NSTextAlignmentCenter];
        [_placeholderLabel setTextColor:[UIColor lightGrayColor]];
        [_placeholderLabel setFont:[UIFont systemFontOfSize:13.0]];
        [self addSubview:_placeholderLabel];
        
        _closeButton = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width - 75, frame.origin.y, 75, frame.size.height)];
        [_closeButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [_closeButton setTintColor:[UIColor whiteColor]];
        [_closeButton.layer setOpacity:0.0];
        [_closeButton addTarget:self action:@selector(cancelButtonWasTapped) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_closeButton];
    }
    return self;
}

- (void) setRightView:(UIView *)rightView
{
    CGRect frame = _searchBarTextField.frame;
    CGRect pFrame = _placeholderLabel.frame;
    _searchBarTextField.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width - rightView.frame.size.width - 8, frame.size.height);
    _placeholderLabel.frame = CGRectMake(pFrame.origin.x, pFrame.origin.y, pFrame.size.width - rightView.frame.size.width - 8, pFrame.size.height);
    _rightView = rightView;
    _rightView.frame = CGRectMake(self.frame.size.width - rightView.frame.size.width - 8, frame.origin.y, rightView.frame.size.width, rightView.frame.size.height);
    
    [self addSubview:_rightView];
}

- (void) setShowsCancelButton:(BOOL)showsCancelButton animated:(BOOL)animated
{
    if (showsCancelButton) {
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         _searchBarTextField.frame = CGRectMake(_searchBarTextField.frame.origin.x, _searchBarTextField.frame.origin.y, (self.frame.size.width - _searchBarTextField.frame.origin.x) - (_closeButton.frame.size.width + 8), _searchBarTextField.frame.size.height);
                         [_closeButton.layer setOpacity:1.0];
                         _placeholderLabel.frame = CGRectOffset(_placeholderLabel.frame, _placeholderLabel.frame.size.width * -0.5 + 45, 0);
                         _rightView.frame = CGRectMake(self.frame.size.width * 1.25, _rightView.frame.origin.y, _rightView.frame.size.width, _rightView.frame.size.height);
                     }
                     completion:nil];
    } else {
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             _searchBarTextField.frame = CGRectMake(_searchBarTextField.frame.origin.x, _searchBarTextField.frame.origin.y, (self.frame.size.width - _searchBarTextField.frame.origin.x) - (_rightView.frame.size.width + 16), _searchBarTextField.frame.size.height);
                              [_closeButton.layer setOpacity:0.0];
                             _placeholderLabel.frame = CGRectOffset(_placeholderLabel.frame, _placeholderLabel.frame.size.width * 0.5 - 45, 0);
                             _placeholderLabel.layer.opacity = 1.0;
                             _rightView.frame = CGRectMake(self.frame.size.width - _rightView.frame.size.width - 8, _rightView.frame.origin.y, _rightView.frame.size.width, _rightView.frame.size.height);
                         }
                         completion:nil];
    }
}

- (void) setText:(NSString *)text
{
    [_searchBarTextField setText:text];
}

- (void) setPlaceholder:(NSString *)placeholder
{
    [_placeholderLabel setText:placeholder];
}

- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    if (!self.isEditing) {
        self.isEditing = YES;
        NSLog(@"text field did begin editin");
        [self.delegate searchBarTextDidBeginEditing:self];
    }
}


- (BOOL) becomeFirstResponder
{
    [_searchBarTextField becomeFirstResponder];
    return YES;
}

- (BOOL) resignFirstResponder
{
    [_searchBarTextField resignFirstResponder];
    return YES;
}

- (void) textFieldDidChange
{
    if (_searchBarTextField.text.length > 0) {
        [UIView animateWithDuration:0.2
                              delay:0.0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             _placeholderLabel.layer.opacity = 0.0;
                         }
                         completion:^(BOOL finished) {
                             
                         }];
    } else {
        [UIView animateWithDuration:0.2
                              delay:0.0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             _placeholderLabel.layer.opacity = 1.0;
                         }
                         completion:^(BOOL finished) {
                             
                         }];
    }
    
    [self.delegate searchBar:self textDidChange:_searchBarTextField.text];
}

- (void) cancelButtonWasTapped
{
    self.isEditing = NO;
    [self.delegate searchBarCancelButtonClicked:self];
}

@end
