//
//  ImagesBank+Storage.h
//  Pad CMS
//
//  Created by Maksym Martyniuk on 10/28/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "ImagesBank.h"

@class ImagesBankImage;

/**
 @brief Define file system interaction for ImageBank class
 */
@interface ImagesBank (Storage)

/**
 @brief Search file with specified name in ImagesBank cache derictory
 @param fileName image cache identifier name
 @return YES if file exists, otherwise NO.
 */
- (BOOL) existsFileWithName:(NSString*)fileName;

/**
 @brief Return image from file for specified name.
 @param name image cache identifier name.
 @return ImagesBankImage object if file exists or nil if no such file.
 @see ImagesBankImage.
 */
- (ImagesBankImage*) storedImageWithName:(NSString*)name;

/**
 @brief Archeaving ImagesBankImage object to ImagesBank cache derictory with specified file name.
 @param name image cache identifier name.
 */
- (void) writeImage:(ImagesBankImage*)image toDiscWithName:(NSString*)fileName;

@end
