//
//  RuePageElementVideo.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 12/2/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "RuePageElementVideo.h"
#import "RueSQLiteKeys.h"

@implementation RuePageElementVideo

- (void)pushElementData:(NSDictionary*)data
{
    [super pushElementData:data];
    
    if([data objectForKey:PCSQLiteElementDisableUserInteractionAttributeName])
    {
        self.userInteractionEnabled = ! [[data objectForKey:PCSQLiteElementDisableUserInteractionAttributeName] boolValue];
    }
    else
    {
        self.userInteractionEnabled = YES;
    }
    
    if([data objectForKey:PCSQLiteElementLoopVideoAttributeName])
    {
        self.loopVideo = [[data objectForKey:PCSQLiteElementLoopVideoAttributeName] boolValue];
    }
}

@end
