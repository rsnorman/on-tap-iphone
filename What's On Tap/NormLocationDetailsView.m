//
//  NormLocationDetailsView.m
//  On Tap
//
//  Created by Ryan Norman on 2/15/14.
//  Copyright (c) 2014 Ryan Norman. All rights reserved.
//

#import "NormLocationDetailsView.h"
#import "constants.h"
#import "TestFlight.h"

@implementation NormLocationDetailsView

UILabel *addressLabel;
UILabel *availableLabel;
UIButton *getDirectionsButton;
UIButton *viewMenuButton;

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self){
        self.locationNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, frame.size.width - 100, 20)];
        [self.locationNameLabel setTextColor:[UIColor blackColor]];
        [self.locationNameLabel setFont:[UIFont boldSystemFontOfSize:16.0]];
        [self.locationNameLabel setNumberOfLines:3];
        [self addSubview:self.locationNameLabel];
        
        self.locationDistanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width - 80, 10, 70, 35)];
        [self.locationDistanceLabel setTextColor:_MAIN_COLOR];
        [self.locationDistanceLabel setFont:[UIFont boldSystemFontOfSize:32]];
        [self.locationDistanceLabel setTextAlignment:NSTextAlignmentRight];
        [self addSubview:self.locationDistanceLabel];
        
        UILabel *mileLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width - 30, 31, 20, 10)];
        [mileLabel setTextColor:_MAIN_COLOR];
        [mileLabel setFont:[UIFont boldSystemFontOfSize:14.0]];
        [mileLabel setText:@"mi"];
        [mileLabel setTextAlignment:NSTextAlignmentRight];
        [self addSubview:mileLabel];
        
        
        addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 40, frame.size.width - 40, 20)];
        [addressLabel setTextColor:_MAIN_COLOR];
        [addressLabel setFont:[UIFont systemFontOfSize:13.0]];
        [addressLabel setText:@"Address"];
        [self addSubview:addressLabel];
        
        
        self.locationAddressLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 60, frame.size.width - 40, 20)];
        [self.locationAddressLabel setTextColor:[UIColor blackColor]];
        [self.locationAddressLabel setFont:[UIFont systemFontOfSize:16.0]];
        [self.locationAddressLabel setNumberOfLines:2];
        [self addSubview:self.locationAddressLabel];
        
        availableLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 115, frame.size.width - 40, 20)];
        [availableLabel setTextColor:_MAIN_COLOR];
        [availableLabel setFont:[UIFont systemFontOfSize:13.0]];
        [availableLabel setText:@"Available"];
        [self addSubview:availableLabel];
        
        self.locationAvailableLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 135, frame.size.width - 40, 20)];
        [self.locationAvailableLabel setTextColor:[UIColor blackColor]];
        [self.locationAvailableLabel setFont:[UIFont systemFontOfSize:16.0]];
        [self.locationAvailableLabel setNumberOfLines:1];
        [self addSubview:self.locationAvailableLabel];
        
        getDirectionsButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 0, frame.size.width / 2 - 20, 30)];
        [getDirectionsButton setTitle:@"Get Directions To Here" forState:UIControlStateNormal];
        [getDirectionsButton setTitleColor:_MAIN_COLOR forState:UIControlStateNormal];
        [getDirectionsButton.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
        [getDirectionsButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [getDirectionsButton addTarget:self action:@selector(getDirections) forControlEvents:UIControlEventTouchUpInside];

        [self addSubview:getDirectionsButton];
        
        viewMenuButton = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width / 2 + 20, 0, frame.size.width / 2 - 20, 30)];
        [viewMenuButton setTitle:@"View What's On Tap" forState:UIControlStateNormal];
        [viewMenuButton setTitleColor:_MAIN_COLOR forState:UIControlStateNormal];
        [viewMenuButton.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
        [viewMenuButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [viewMenuButton addTarget:self action:@selector(getLocationMenu) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:viewMenuButton];
        
        _hidden = YES;
    }
    
    return self;
}

- (void) getLocationMenu
{
    [self.delegate didSelectViewLocationMenu];
}

- (void) getDirections
{
    [TestFlight passCheckpoint:@"Got Directions for Location"];
    NSString* versionNum = [[UIDevice currentDevice] systemVersion];
    NSString *nativeMapScheme = @"maps.apple.com";
    if ([versionNum compare:@"6.0" options:NSNumericSearch] == NSOrderedAscending){
        nativeMapScheme = @"maps.google.com";
    }
    NSString* url = [NSString stringWithFormat: @"http://%@/maps?saddr=%f,%f&daddr=%f,%f", nativeMapScheme, self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude,
                     [_location getCoordinate].latitude, [_location getCoordinate].longitude];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

- (void) setLocation:(Location *)location
{
    _location = location;
    self.locationNameLabel.frame = CGRectMake(20, 20, self.frame.size.width - 100, 20);
    [self.locationNameLabel setText:location.name];
    [self.locationNameLabel sizeToFit];
    
    self.locationAddressLabel.frame = CGRectMake(20, 60, self.frame.size.width - 40, 20);
    [self.locationAddressLabel setText:location.address];
    [self.locationAddressLabel sizeToFit];
    
    self.locationAvailableLabel.frame = CGRectMake(20, 135, self.frame.size.width - 40, 20);
    if (location.inventory.length > 0) {
        [self.locationAvailableLabel setText:location.inventory];
    } else {
        [self.locationAvailableLabel setText:@"Not Available"];
    }
    [self.locationAvailableLabel sizeToFit];
    
    NSArray *pieces = [self.location.distanceAway componentsSeparatedByString:@" miles away"];
    [self.locationDistanceLabel setText:[NSString stringWithFormat:@"%@", [pieces objectAtIndex:0]]];
    [self.locationDistanceLabel sizeToFit];
    self.locationDistanceLabel.frame = CGRectMake(self.frame.size.width - self.locationDistanceLabel.frame.size.width - 32, self.locationDistanceLabel.frame.origin.y, self.locationDistanceLabel.frame.size.width, self.locationDistanceLabel.frame.size.height);
    
    addressLabel.frame = CGRectMake(20, self.locationNameLabel.frame.size.height + self.locationNameLabel.frame.origin.y + 15, self.frame.size.width - 40, addressLabel.frame.size.height);
    self.locationAddressLabel.frame = CGRectMake(20, addressLabel.frame.size.height + addressLabel.frame.origin.y  + 2, self.frame.size.width - 40, self.locationAddressLabel.frame.size.height);
    
    availableLabel.frame = CGRectMake(20, self.locationAddressLabel.frame.size.height + self.locationAddressLabel.frame.origin.y + 10, self.frame.size.width - 40, availableLabel.frame.size.height);
    self.locationAvailableLabel.frame = CGRectMake(20, availableLabel.frame.size.height + availableLabel.frame.origin.y  + 2, self.frame.size.width - 40, self.locationAvailableLabel.frame.size.height);
    
    getDirectionsButton.frame = CGRectMake(20, self.locationAvailableLabel.frame.size.height + self.locationAvailableLabel.frame.origin.y  + 15, getDirectionsButton.frame.size.width, getDirectionsButton.frame.size.height);
    
    viewMenuButton.frame = CGRectMake(viewMenuButton.frame.origin.x, self.locationAvailableLabel.frame.size.height + self.locationAvailableLabel.frame.origin.y  + 15, viewMenuButton.frame.size.width, viewMenuButton.frame.size.height);
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, viewMenuButton.frame.origin.y + 40);
}

@end
