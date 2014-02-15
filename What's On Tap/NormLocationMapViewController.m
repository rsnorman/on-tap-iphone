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

@interface NormLocationMapViewController () <MKMapViewDelegate>

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
        
        self.locationDetailsView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height / 2)];
        [self.locationDetailsView setBackgroundColor:[UIColor whiteColor]];
        [self.locationDetailsView.layer setShadowColor:[UIColor darkGrayColor].CGColor];
        [self.locationDetailsView.layer setShadowRadius:3.0];
        [self.locationDetailsView.layer setShadowOpacity:0.8];
        [self.locationDetailsView.layer setOpacity:0.8];
        
        [self.view addSubview:self.locationDetailsView];
        
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
    
    NSMutableArray *annotations = [[NSMutableArray alloc] init];
    
    for (Location *location in self.locations) {
//        NormBarLocationView * barPlacemark = [[NormBarLocationView alloc] initWithLocation:location];
        NormBarLocationItem *barItem = [[NormBarLocationItem alloc] init];
//        barItem.coordinate = [location getCoordinate];
//        barItem.latitude = [[NSNumber alloc] initWithFloat: [location.latitude floatValue]];
//        barItem.longitude = [[NSNumber alloc] initWithFloat: [location.longitude floatValue]];
        barItem.location = location;
//        NormBarLocationView *barPlacemark = [[NormBarLocationView alloc] initWithAnnotation:barItem reuseIdentifier:@"baritem"];
        
        [self.mapView addAnnotation:barItem];
        [annotations addObject:barItem];
//        [self.mapView addAnnotation:(id)barPlacemark];
//        [annotations addObject:barPlacemark];
        
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
//        customPinView.location = ((NormBarLocationItem *)annotation).location;
        
        // add a detail disclosure button to the callout which will open a new view controller page
        //
        // note: when the detail disclosure button is tapped, we respond to it via:
        //       calloutAccessoryControlTapped delegate method
        //
        // by using "calloutAccessoryControlTapped", it's a convenient way to find out which annotation was tapped
        //
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

//- (void) mapView:(MKMapView *)mapView didSelectAnnotationView:(NormBarLocationView *)view
//{
//    self.selectedLocation = ((NormBarLocationItem *)view.annotation).location;
//    if (isDoneRendering) {
//        [self showMoreLocationDetails];
//    }
//}
//
//- (void) mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered
//{
//    isDoneRendering = YES;
//    
//    if (self.selectedLocation) {
//        [self showMoreLocationDetails];
//    }
//}

- (void) showMoreLocationDetails
{
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.locationDetailsView.frame = CGRectOffset(self.locationDetailsView.frame, 0, self.view.frame.size.height / 2 * -1);
                     }                   completion:nil
     ];
}

@end
