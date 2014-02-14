//
//  NormStyleMenuDelegate.h
//  On Tap
//
//  Created by Ryan Norman on 2/10/14.
//  Copyright (c) 2014 Ryan Norman. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NormServeTypeMenuDelegate <NSObject>

- (void)didSelectLocationFinder;
- (void)didSelectServeType:(NSString *)serveType;
@end
