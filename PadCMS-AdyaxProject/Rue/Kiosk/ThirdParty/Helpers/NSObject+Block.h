//
//  NSObject+Block.h
//  Quiz
//
//  Created by Martyniuk.M on 2/26/13.
//  Copyright (c) 2013 DBBest. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Block)

- (void) performBlock:(void(^)(void))block afterDealay:(NSTimeInterval)dealay;

+ (void) performInBackground:(void(^)(void))block;
- (void) performInBackground:(void(^)(void))block;
- (void) performInBackground:(void(^)(void))block completion:(void(^)(void))completionBlock;

@end
