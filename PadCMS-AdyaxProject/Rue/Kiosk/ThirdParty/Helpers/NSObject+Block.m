//
//  NSObject+Block.m
//  Quiz
//
//  Created by Martyniuk.M on 2/26/13.
//  Copyright (c) 2013 DBBest. All rights reserved.
//

#import "NSObject+Block.h"

@implementation NSObject (Block)

- (void) performBlock:(void(^)(void))block afterDealay:(NSTimeInterval)dealay
{
    [self performSelector:@selector(performBlock:) withObject:block afterDelay:dealay];
}

- (void) performBlock:(void(^)(void))block
{
    block();
}

- (void) performBlockWithParams:(NSDictionary*)params
{
    void(^block)(void) = [params objectForKey:@"block"];
    void(^complBlock)(void) = [params objectForKey:@"compl"];
    block();
    [self performSelectorOnMainThread:@selector(performBlock:) withObject:complBlock waitUntilDone:NO];
}

+ (void) performInBackground:(void(^)(void))block
{
    NSObject* obj = [[NSObject alloc]init];
    [obj performSelectorInBackground:@selector(performBlock:) withObject:block];
}

- (void) performInBackground:(void(^)(void))block
{
    [self performSelectorInBackground:@selector(performBlock:) withObject:block];
}

- (void) performInBackground:(void(^)(void))block completion:(void(^)(void))completionBlock
{
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:[block copy], @"block", [completionBlock copy], @"compl", nil];
    [self performSelectorInBackground:@selector(performBlockWithParams:) withObject:params];
}

- (void) performBlock:(void(^)(void))block afterDealay:(NSTimeInterval)dealay completion:(void(^)(void))completionBlock
{
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:[block copy], @"block", [completionBlock copy], @"compl", nil];
    [self performSelector:@selector(performBlockWithParams:) withObject:params afterDelay:dealay];
}

@end
