//
//  NormBarLocationView.m
//  On Tap
//
//  Created by Ryan Norman on 2/13/14.
//  Copyright (c) 2014 Ryan Norman. All rights reserved.
//

#import "NormBarLocationView.h"

@interface NormBarLocationView ()
@property (nonatomic, retain) Location *location;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@end

@implementation NormBarLocationView

- (id)initWithLocation:(Location *)location
{
    self = [super init];
    
    if (self) {
        self.location = location;
    }
    
    return self;
}

- (NSString *)title {
    return _location.name;
}

- (NSString *)subtitle {
    return [NSString stringWithFormat:@"%@", _location.address];
}

- (CLLocationCoordinate2D)coordinate {
    return [self.location getCoordinate];
}

- (MKMapItem*)mapItem {
    NSDictionary *addressDict = @{self.location.name : self.location.address};
    
    MKPlacemark *placemark = [[MKPlacemark alloc]
                              initWithCoordinate:[self.location getCoordinate]
                              addressDictionary:addressDict];
    
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    mapItem.name = self.title;
    
    return mapItem;
}


@end
