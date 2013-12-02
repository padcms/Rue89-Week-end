//
//  RuePageElementBackground.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 11/26/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "RuePageElementBackground.h"
#import "RueSQLiteKeys.h"

@implementation RuePageElementBackground

- (void)pushElementData:(NSDictionary*)data
{
    [super pushElementData:data];
    
    if([data objectForKey:PCSQLiteElementShowOnTopAttributeName])
    {
        self.showOnTop = [[data objectForKey:PCSQLiteElementShowOnTopAttributeName]boolValue] ;
    }
}

@end
