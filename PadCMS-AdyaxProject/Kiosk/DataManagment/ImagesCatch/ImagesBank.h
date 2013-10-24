//
//  ImagesBank.h
//  ClosetSwap
//
//  Created by Martyniuk.M on 7/22/13.
//  Copyright (c) 2013 DBBest. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImagesBank : NSObject

- (void) getImageNamed:(NSString*)imageName toBlock:(void(^)(UIImage* image, NSError* error, BOOL isThumbForVideo))completionBlock;
- (void) pushImage:(UIImage*)image named:(NSString*)imageName completionBlock:(void (^)(NSError* error))completionBlock;
- (void) removeImageNamed:(NSString*)imageName completionBlock:(void(^)(NSError *error))completionBlock;

@end
