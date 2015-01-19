//
//  NormStyleMenu.m
//  On Tap
//
//  Created by Ryan Norman on 2/10/14.
//  Copyright (c) 2014 Ryan Norman. All rights reserved.
//

#import "NormServeTypeMenu.h"
#import "constants.h"

@implementation NormServeTypeMenu

- (id)init
{
    self = [super init];
    if (self) {
        self.appearsBehindNavigationBar = NO; // Affects only iOS 7
        self.backgroundColor = _DARK_COLOR;
        self.font = [UIFont fontWithName:_PRIMARY_FONT size:22];
        self.subtitleFont = [UIFont fontWithName:_PRIMARY_FONT size:14];
        self.textColor = [UIColor lightGrayColor];
        self.separatorColor = [UIColor darkGrayColor];
        
        if (!REUIKitIsFlatMode()) {
            self.cornerRadius = 4;
            self.shadowRadius = 4;
            self.shadowColor = [UIColor blackColor];
            self.shadowOffset = CGSizeMake(0, 1);
            self.shadowOpacity = 1;
        }
        
        self.imageOffset = CGSizeMake(8, -1);
        self.waitUntilAnimationIsComplete = NO;
        self.badgeLabelConfigurationBlock = ^(UILabel *badgeLabel, REMenuItem *item) {
            badgeLabel.backgroundColor = _MAIN_COLOR;
            badgeLabel.layer.borderWidth = 0.0;
            badgeLabel.textColor = [UIColor whiteColor];
            badgeLabel.layer.cornerRadius = 10.0;
            badgeLabel.layer.frame = CGRectMake(25.0, 10.0, 20.0, 20.0);
        };
    }
    return self;
}

- (void) setServeTypes:(NSArray *)serveTypes withBeerCounts:(NSArray *)beerCounts
{
    self.beerServeTypes = serveTypes;
    
    __typeof (self.delegate) __weak weakSelf = self.delegate;

    NSMutableArray *menuItems = [[NSMutableArray alloc] init];
    
    int count = 0;
    
    for (NSString* serveType in self.beerServeTypes)
    {
        UIImage * menuItemImage = nil;

        if ([serveType isEqual:@"On Tap"] || [serveType isEqual:@"Featured"] || [serveType isEqual:@"House"]) {
            menuItemImage = [UIImage imageNamed: @"glass-menu-item"];
        } else if([serveType isEqual:@"Bottles"]){
            menuItemImage = [UIImage imageNamed:@"bottle-menu-item"];
        }  else if([serveType isEqual:@"Cans"]){
            menuItemImage = [UIImage imageNamed:@"can-menu-item"];
        } else {
            menuItemImage = [UIImage imageNamed: @"glass-menu-item"];
        }


        REMenuItem *menuItem = [[REMenuItem alloc] initWithTitle:serveType
                                                              image:menuItemImage
                                                   highlightedImage:nil
                                                             action:^(REMenuItem *item) {
                                                                 [weakSelf didSelectServeType:item.title];
                                                             }];

        NSNumber *beerCount = [beerCounts objectAtIndex:count];
        [menuItem setBadge:[NSString stringWithFormat:@"%lu", (unsigned long)[beerCount integerValue]]];
        count = count + 1;

        [menuItems addObject:menuItem];
    }
    
    
    if (self.locationMenuItem != nil) {
        [menuItems addObject:self.locationMenuItem];
    }
    
    [self setItems:menuItems];
}

- (void) setLocation:(Location *)location
{
    if (self.locationMenuItem == nil) {
        __typeof (self.delegate) __weak weakSelf = self.delegate;
        self.locationMenuItem = [[REMenuItem alloc] initWithTitle:@"Locations"
                                                                   image:nil
                                                        highlightedImage:nil
                                                                  action:^(REMenuItem *item) {
                                                                      [weakSelf didSelectLocationFinder];
                                                                  }];
        
        
        NSMutableArray *menuItems = [[NSMutableArray alloc] initWithArray:self.items];
        [menuItems addObject:self.locationMenuItem];
        [self setItems:menuItems];
    }
    
    [self.locationMenuItem setSubtitle:location.name];
}

@end
