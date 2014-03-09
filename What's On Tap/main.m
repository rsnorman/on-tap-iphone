//
//  main.m
//  What's On Tap
//
//  Created by Ryan Norman on 11/28/13.
//  Copyright (c) 2013 Ryan Norman. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NormAppDelegate.h"

int main(int argc, char * argv[])
{
    @autoreleasepool {
        id _klass = [NormAppDelegate class];
        NSString *appString = NSStringFromClass(_klass);
        return UIApplicationMain(argc, argv, nil, appString);
    }
}
