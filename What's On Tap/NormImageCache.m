//
//  NormImageCache.m
//  What's On Tap
//
//  Created by Ryan Norman on 12/15/13.
//  Copyright (c) 2013 Ryan Norman. All rights reserved.
//

#import "NormImageCache.h"

@implementation NormImageCache

- (void)setImage:(UIImage *)image forKey:(NSString *)key
{
    [_imageCache setObject:image forKey:key];
    [self saveImage:image forURL:key];
}
     
 -(void) saveImage:(UIImage *)image forURL:(NSString *)url {
     NSString * extension = [url componentsSeparatedByString:@"."].lastObject;
     NSString * directoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
     NSString * imageName = [url componentsSeparatedByString:@"/"].lastObject;
     
     if ([[extension lowercaseString] isEqualToString:@"png"]) {
         [UIImagePNGRepresentation(image) writeToFile:[directoryPath stringByAppendingPathComponent:imageName] options:NSAtomicWrite error:nil];
     } else if ([[extension lowercaseString] isEqualToString:@"jpg"] || [[extension lowercaseString] isEqualToString:@"jpeg"]) {
         [UIImageJPEGRepresentation(image, 1.0) writeToFile:[directoryPath stringByAppendingPathComponent:imageName] options:NSAtomicWrite error:nil];
     } else {
         NSLog(@"Image Save Failed\nExtension: (%@) is not recognized, use (PNG/JPG)", extension);
     }
 }

-(UIImage *) retrieveImageForURL:(NSString *)url
{
    NSString * directoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * imageName = [url componentsSeparatedByString:@"/"].lastObject;
    
    NSData *imageData = [NSData dataWithContentsOfFile:[directoryPath stringByAppendingPathComponent:imageName]];
    UIImage *image = [UIImage imageWithData:imageData];
    
    return image;
}

- (UIImage *)imageForKey:(NSString *)key
{
    UIImage *image = [self.imageCache objectForKey:key];
    
    if (image) {
        return image;
    } else {
        image = [self retrieveImageForURL:key];
        
        if (image) {
            [self setImage:image forKey:key];
        }
        
        return image;
    }
}

- (id)init
{
    self = [super init];
    
    if (self) {
        NSLog(@"Image cache initialized");
        _imageCache = [[NSCache alloc] init];
    }
    
    return self;
}

@end
