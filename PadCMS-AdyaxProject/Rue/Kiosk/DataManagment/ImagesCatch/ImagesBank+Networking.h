//
//  ImagesBank+Networking.h
//  Pad CMS
//
//  Created by Maksym Martyniuk on 10/28/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "ImagesBank.h"

/**
 @brif Defined network interaction for ImagesBank class
 */
@interface ImagesBank (Networking)

/**
 @brief Send HEAD request for file with specified path and retutns its last modified date from http protocol thru block or error if operation not possible.
 @warning Not downloading file and just get its header.
 @param path full file path
 @param completionBlock block that executes when operation complete
 */
- (void) findImageInNetworkWithPath:(NSString*)path completion:(void(^)(NSDate* lastModifiedDate, NSError* error))complBlock;

/**
 @brief Download image file with specified path from network and retutns UIImage instance and its last modified date thru block or error if operation not possible.
 @param path full file path
 @param completionBlock block that executes when operation complete
 */
- (void) downloadImageFromPath:(NSString*)path completion:(void(^)(UIImage* image, NSDate* lastModifiedDate, NSError* error))complBlock;

@end
