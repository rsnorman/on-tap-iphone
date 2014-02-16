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
#import "NormLocationDetailsView.h"
#import "NormDrawerController.h"

@protocol NormLocationMapViewControllerDelegate <NSObject>

- (void) didSelectViewLocationMenu:(Location *)location;

@end

@interface NormLocationMapViewController : UIViewController

@property id<NormLocationMapViewControllerDelegate> delegate;
@property (retain, nonatomic) MKMapView *mapView;
@property (retain, nonatomic) UINavigationBar *navigationBar;
@property (retain, nonatomic) UILabel *navBarTitle;
@property (retain, nonatomic) NSArray *locations;
@property (retain, nonatomic) NormLocationDetailsView *locationDetailsView;
@property (retain, nonatomic) NormDrawerController *locationDetailsDrawerController;
@property CLLocation *userLocation;
@property (retain, nonatomic) Location *selectedLocation;

@end
