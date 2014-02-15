//
//  NormLocationMapControllerViewController.h
//  On Tap
//
//  Created by Ryan Norman on 2/12/14.
//  Copyright (c) 2014 Ryan Norman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Location.h"

@interface NormLocationMapViewController : UIViewController
@property (retain, nonatomic) MKMapView *mapView;
@property (retain, nonatomic) UINavigationBar *navigationBar;
@property (retain, nonatomic) UILabel *navBarTitle;
@property (retain, nonatomic) NSArray *locations;
@property (retain, nonatomic) UIView *locationDetailsView;
@property CLLocation *userLocation;
@property (retain, nonatomic) Location *selectedLocation;

@end
