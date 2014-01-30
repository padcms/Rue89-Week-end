//
//  RueAccessManager.h
//  Pad CMS
//
//  Created by Maksym Martyniuk on 11/26/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kPublisherAccessNumberOfTouches 2

/**@brief Manages access to unpublished issues*/
@interface RueAccessManager : NSObject

/**@brief Send conform request for password and remember it if conformation successful.
 @param password password to confirm
 @param completionBlock block that executes when conformation complete. If password was conformed successfuly error parameter is nil.*/

+ (void) confirmPassword:(NSString*)password completion:(void(^)(NSError* error))completionBlock;

/**@brief Returns password if that was confirmed, otherwise returns @"".*/

+ (NSString*) publisherPassword;

/**@brief Returns YES if publisher password was confirmed, otherwise returns NO.*/

+ (BOOL) isInPublisherMode;

@end
