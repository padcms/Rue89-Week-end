//
//  PCResourceCache+MemoryWarning.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 12/31/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCResourceCache.h"

@interface PCResourceCache ()

@property NSCache *cache;

@end

static PCResourceCache *defaultResourceCache;

@implementation PCResourceCache (MemoryWarning)

+ (PCResourceCache *)defaultResourceCache
{
    if (defaultResourceCache == nil) {
        defaultResourceCache = [[super allocWithZone:NULL] init];
        defaultResourceCache.cache = [[NSCache alloc] init];
        defaultResourceCache.cache.delegate = defaultResourceCache;
        [[NSNotificationCenter defaultCenter] addObserver:defaultResourceCache selector:@selector(dedReceiveMemoryWarning) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    
    return defaultResourceCache;
}

- (void) dedReceiveMemoryWarning
{
    [self.cache removeAllObjects];
    NSLog(@"Resource cache was cleaned.");
}

@end
