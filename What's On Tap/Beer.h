//
//  Beer.h
//  On Tap
//
//  Created by Ryan Norman on 1/25/14.
//  Copyright (c) 2014 Ryan Norman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Beer : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * bID;
@property (nonatomic, retain) NSString * serveType;
@property (nonatomic, retain) NSString * style;
@property (nonatomic, retain) NSString * styleCategory;
@property (nonatomic, retain) NSNumber * abv;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) NSString * servedIn;
@property (nonatomic, retain) NSString * breweryName;
@property (nonatomic, retain) NSString * breweryLink;
@property (nonatomic, retain) NSString * label;
@property (nonatomic, retain) NSString * thumbnailLabel;
@property (nonatomic, retain) NSString * summary;
@property (nonatomic, retain) NSString * menuID;

@end
