//
//  NormLocationMapControllerViewController.m
//  On Tap
//
//  Created by Ryan Norman on 2/12/14.
//  Copyright (c) 2014 Ryan Norman. All rights reserved.
//

#import "NormLocationMapViewController.h"
#import "NormBarLocationView.h"
#import "constants.h"

@interface NormLocationMapViewController ()

@end

@implementation NormLocationMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
        self.navigationBar.barTintColor = _MAIN_COLOR;
        self.navigationBar.translucent = YES;
        [self.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
        [self.view addSubview:self.navigationBar];
        
        
        UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 20, 60, 40)];
        [closeButton setTitle:@"close" forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
        [self.navigationBar addSubview:closeButton];
        
        _navBarTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 160, 60)];
        [_navBarTitle setText:@"Nearby Locations"];
        [_navBarTitle setFont:[UIFont boldSystemFontOfSize:18]];
        [_navBarTitle setTextColor:[UIColor whiteColor]];
        [_navBarTitle setCenter:CGPointMake(self.navigationBar.frame.size.width / 2, self.navigationBar.frame.size.height - 20)];
        [_navBarTitle setTextAlignment:NSTextAlignmentCenter];
        [self.navigationBar addSubview:_navBarTitle];
        
        
        [self.view setBackgroundColor:_DARK_COLOR];
        self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, self.navigationBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - self.navigationBar.frame.size.height)];
        [self.mapView setUserTrackingMode:MKUserTrackingModeFollow];
        
        [self.view addSubview:self.mapView];
    }
    return self;
}

- (void)viewDidLoad
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    float minLatitude = self.userLocation.coordinate.latitude;
    float minLongitude = self.userLocation.coordinate.longitude;
    
    float maxLatitude = self.userLocation.coordinate.latitude;
    float maxLongitude = self.userLocation.coordinate.longitude;
    
    NSMutableArray *annotations = [[NSMutableArray alloc] init];
    
    for (Location *location in self.locations) {
        NormBarLocationView * barPlacemark = [[NormBarLocationView alloc] initWithLocation:location];
        
        [self.mapView addAnnotation:(id)barPlacemark];
        [annotations addObject:barPlacemark];
        
        CLLocationCoordinate2D coordinate = [location getCoordinate];
        if (minLatitude > coordinate.latitude) {
            minLatitude = coordinate.latitude;
        }
        if (minLongitude > coordinate.longitude) {
            minLongitude = coordinate.longitude;
        }
        if (maxLatitude < coordinate.latitude) {
            maxLatitude = coordinate.latitude;
        }
        if (maxLongitude < coordinate.longitude) {
            maxLongitude = coordinate.longitude;
        }
    }
    
    CLLocation *minLocation = [[CLLocation alloc] initWithLatitude:minLatitude longitude:minLongitude];
    CLLocation *maxLocation = [[CLLocation alloc] initWithLatitude:maxLatitude longitude:maxLongitude];
    
    CLLocationDistance distanceFromUserInMeters = [minLocation distanceFromLocation:maxLocation];

    MKCoordinateRegion region;
    region.center.latitude = (minLocation.coordinate.latitude + maxLocation.coordinate.latitude) / 2.0;
    region.center.longitude = (minLocation.coordinate.longitude + maxLocation.coordinate.longitude) / 2.0;
    region.span.latitudeDelta = distanceFromUserInMeters / 111319.5 * 2;
    region.span.longitudeDelta = 0.0;
    
    MKCoordinateRegion _savedRegion = [_mapView regionThatFits:region];
    [_mapView setRegion:_savedRegion animated:NO];
    
    if (self.locations.count == 1) {
        [self.navBarTitle setText: ((Location *)[self.locations objectAtIndex:0]).name];
        [self.mapView selectAnnotation:[annotations objectAtIndex:0] animated:NO];
    }
}

- (void)close
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
