//
//  NormImageCache.h
//  What's On Tap
//
//  Created by Ryan Norman on 12/15/13.
//  Copyright (c) 2013 Ryan Norman. All rights reserved.
//

#import <Foundation/Foundation.h>

// Caches JPG and PNG images in a local folder for easy retrieval at a later time
@interface NormImageCache : NSObject

// Sets an image for a key
+ (void)setImage:(UIImage *)image forKey:(NSString *)key;

// Retrieves an image matching a key
+ (UIImage *)imageForKey:(NSString *)key;

// Saves an image from a URL
+ (void)saveImage:(UIImage *)image forURL:(NSString *)url;

@end
