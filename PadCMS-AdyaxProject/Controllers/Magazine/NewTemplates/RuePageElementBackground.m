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
    self.resource = [data objectForKey:PCSQLiteElementResourceAttributeName];
    if ([data objectForKey:PCSQLiteElementHeightAttributeName])
        size.height = [[data objectForKey:PCSQLiteElementHeightAttributeName] floatValue];
    
    if ([data objectForKey:PCSQLiteElementWidthAttributeName])
        size.width = [[data objectForKey:PCSQLiteElementWidthAttributeName] floatValue];
    
    if([data objectForKey:PCSQLiteElementShowOnTopAttributeName])
    {
        self.showOnTop = [[data objectForKey:PCSQLiteElementShowOnTopAttributeName]boolValue] ;
    }
}

@end
