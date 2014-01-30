//
//  ImagesBank.h
//  ClosetSwap
//
//  Created by Martyniuk.M on 7/22/13.
//  Copyright (c) 2013 DBBest. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 @brief Caching images dowloading from internet and stores it on disk and to the memory
 */
@interface ImagesBank : NSObject

/**
 @brief Singleton object that catching downloaded from internet images. 
 @brief Memory cache size is equal 20 images. It's mean that in memory exists not more than 20 last requested images at a time. But all images stored on disk.
 @brief When application receives memory warning all cached images removing from memory but stay on disk.
 */
+ (ImagesBank*) sharedBank;

/**
 @brief Download image from internet by specified file path or get it from memory by specified name if image was aleready downloaded thru block.
 @brief If image with specified name exists in memory then completionBlock calls with that image as "image" parameter and nil as "error" parameter. If image with specified name not exists in memory then searching file with that name on disk and if such file exists then updating it if needed or possible from internet (by last modified date) in background ant return thru block. If image not foundet in memory or disk then it downloading and caching in background an returning thru block.
 @param name unique string which identifies image in cache.
 @param imagePath full path for image as web resource
 @param completionBlock block of code that calles on main tread with UIImage parameter when image is ready or NSError parameter if can not get image
 @warning Downloaded image scales if needed to size defined with static constant fixedSize before caching for non-retina devices if image has double (retina) size. It need for memory optimization.
 @see fixedSize
 */
- (void) getImageWithName:(NSString*)name path:(NSString*)imagePath toBlock:(void(^)(UIImage* image, NSError* error))completionBlock;

@end
