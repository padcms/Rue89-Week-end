//
//  RuePageElementSound.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 12/26/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "RuePageElementSound.h"
#import "RueSQLiteKeys.h"

@implementation RuePageElementSound

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
    
    if([data objectForKey:PCSQLiteElementLoopSoundAttributeName])
    {
        self.loopSound = [[data objectForKey:PCSQLiteElementLoopSoundAttributeName] boolValue];
    }
}

@end
