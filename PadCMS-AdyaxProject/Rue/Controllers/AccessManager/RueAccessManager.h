//
//  RueAccessManager.h
//  Pad CMS
//
//  Created by Maksym Martyniuk on 11/26/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kPublisherAccessNumberOfTouches 2

@interface RueAccessManager : NSObject

+ (void) confirmPassword:(NSString*)password completion:(void(^)(NSError* error))completionBlock;

+ (NSString*) publisherPassword;

+ (BOOL) isInPublisherMode;

@end
