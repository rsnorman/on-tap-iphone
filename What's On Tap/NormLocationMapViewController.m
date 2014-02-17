//
//  NormLocationMapControllerViewController.m
//  On Tap
//
//  Created by Ryan Norman on 2/12/14.
//  Copyright (c) 2014 Ryan Norman. All rights reserved.
//

#import "NormLocationMapViewController.h"
#import "NormBarLocationView.h"
#import "NormBarLocationItem.h"
#import "constants.h"
#import "TestFlight.h"

@interface NormLocationMapViewController () <MKMapViewDelegate, NormDrawerControllerDelegate, NormLocationDetailsViewDelegate>

@end

@implementation NormLocationMapViewController

BOOL isDoneRendering;

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
        [self.mapView setDelegate:self];
        
        [self.view addSubview:self.mapView];
        
        
        self.locationDetailsView = [[NormLocationDetailsView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height / 2)];
        [self.locationDetailsView setDelegate:self];
        
        self.locationDetailsDrawerController = [[NormDrawerController alloc] initWithDelegate: self];
        [self.locationDetailsDrawerController setDrawerView:self.locationDetailsView];
        
        isDoneRendering = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    float minLatitude = self.userLocation.coordinate.latitude;
    float minLongitude = self.userLocation.coordinate.longitude;
    
    float maxLatitude = self.userLocation.coordinate.latitude;
    float maxLongitude = self.userLocation.coordinate.longitude;
    
    for (Location *location in self.locations) {
        
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
}

- (void) mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered
{
    if (!isDoneRendering) {
        NSMutableArray *annotations = [[NSMutableArray alloc] init];
        
        for (Location *location in self.locations) {
            NormBarLocationItem *barItem = [[NormBarLocationItem alloc] init];
            
            barItem.location = location;
            
            [self.mapView addAnnotation:barItem];
            [annotations addObject:barItem];
            
        }
        
        if (self.locations.count == 1) {
            [self.navBarTitle setText: ((Location *)[self.locations objectAtIndex:0]).name];
            [self.mapView selectAnnotation:[annotations objectAtIndex:0] animated:NO];
        }
        
        isDoneRendering = YES;
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    // in case it's the user location, we already have an annotation, so just return nil
    if ([annotation isKindOfClass:[MKUserLocation class]])
    {
        return nil;
    }
    
    // try to dequeue an existing pin view first
    static NSString *BarAnnotationIdentifier = @"barAnnotationIdentifier";
    
    MKPinAnnotationView *pinView =
    (MKPinAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:BarAnnotationIdentifier];
    if (pinView == nil)
    {
        // if an existing pin view was not available, create one
        NormBarLocationView *customPinView = [[NormBarLocationView alloc]
                                              initWithAnnotation:annotation reuseIdentifier:BarAnnotationIdentifier];

        customPinView.canShowCallout = YES;
        customPinView.animatesDrop = YES;

        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [rightButton addTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
        customPinView.rightCalloutAccessoryView = rightButton;
        
        return customPinView;
    }
    else
    {
        pinView.annotation = annotation;
    }
    return pinView;
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

- (void) mapView:(MKMapView *)mapView annotationView:(NormBarLocationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    if (self.selectedLocation != [view getLocation]) {
        self.selectedLocation = [view getLocation];
        [self showMoreLocationDetails];
        
        [TestFlight passCheckpoint:@"Opened Drawer For Location"];
    } else {
        self.selectedLocation = nil;
        [self hideMoreLocationDetails];
        [TestFlight passCheckpoint:@"Closed Drawer For Location"];
    }
}

- (void) mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    self.selectedLocation = nil;
    [self.locationDetailsDrawerController close];
    
    [TestFlight passCheckpoint:@"Opened Drawer For Location By Deselecting"];
}

- (void) willCloseDrawer:(UIView *)drawer
{
    self.selectedLocation = nil;
}


- (void) showMoreLocationDetails
{
    [self.locationDetailsView setCurrentLocation:self.userLocation];
    [self.locationDetailsView setLocation:self.selectedLocation];
    [self.locationDetailsDrawerController open];
}

- (void) hideMoreLocationDetails
{
    [self.locationDetailsDrawerController close];
}

- (void) didSelectViewLocationMenu
{
    [TestFlight passCheckpoint:@"Opened Menu From Map"];
    [self.delegate didSelectViewLocationMenu:self.selectedLocation];
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:^{
        
    }];
    
}

@end
