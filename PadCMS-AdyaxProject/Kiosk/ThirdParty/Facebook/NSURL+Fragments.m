//
//  NSURL+Fragments.m
//  ClosetSwap
//
//  Created by Martyniuk.M on 9/5/13.
//  Copyright (c) 2013 DBBest. All rights reserved.
//

#import "NSURL+Fragments.h"

@implementation NSURL (Fragments)

- (NSDictionary*) queryFragments
{
    NSMutableDictionary* resultDictionary = [[NSMutableDictionary alloc]init];
    
    NSString* queryStr = [self query];
    
    if(queryStr)
    {
        NSArray* queryComponets = [queryStr componentsSeparatedByString:@"&"];
        for (NSString* component in queryComponets)
        {
            NSArray* keyValue = [component componentsSeparatedByString:@"="];
            if(keyValue.count > 1)
                [resultDictionary setValue:keyValue[1] forKey:keyValue[0]];
        }
    }
    
    NSString* fragmentStr = self.fragment;
    
    if(fragmentStr)
    {
        NSArray* fragmentComponents = [fragmentStr componentsSeparatedByString:@"&"];
        for (NSString* component in fragmentComponents)
        {
            NSArray* keyValue = [component componentsSeparatedByString:@"="];
            if(keyValue.count > 1)
                [resultDictionary setValue:keyValue[1] forKey:keyValue[0]];
        }
    }
    return [NSDictionary dictionaryWithDictionary:resultDictionary];
}

@end
