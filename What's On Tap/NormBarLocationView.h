//
//  NormBarLocationView.h
//  On Tap
//
//  Created by Ryan Norman on 2/13/14.
//  Copyright (c) 2014 Ryan Norman. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "Location.h"

@interface NormBarLocationView : MKAnnotationView

- (id)initWithLocation:(Location*)location;
- (MKMapItem*)mapItem;

@end