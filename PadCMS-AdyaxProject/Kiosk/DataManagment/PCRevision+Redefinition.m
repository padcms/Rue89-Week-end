//
//  PCRevision+Redefinition.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 10/24/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCRevision.h"
#import <objc/runtime.h>
#import "PCPage.h"
#import "PCColumn.h"

@implementation PCRevision (Redefinition)

+ (void) load
{
    Method oldUpdateColumnsMethod = class_getInstanceMethod([PCRevision class], @selector(updateColumns));
    Method newUpdateColumnsMethod = class_getInstanceMethod([PCRevision class], @selector(updateColumnsRedefined));
    method_exchangeImplementations(oldUpdateColumnsMethod, newUpdateColumnsMethod);
}

- (void)updateColumnsRedefined
{
    [self.columns removeAllObjects];
    
    NSMutableArray *pagesForColumn = [[NSMutableArray alloc] init];
    
    PCPage* coverPage = [self coverPage];
    
    PCPage *firstColumnPage = coverPage ? coverPage : [self pgeWithNoLeftOrTopConnectors];
    
    while (firstColumnPage != nil)
    {
        [pagesForColumn removeAllObjects];
        
        PCPage *nextPage = firstColumnPage;
        while (nextPage != nil)
        {
            if ([firstColumnPage color] != nil)
            {
                [nextPage setColor:[firstColumnPage color]];
            }
            
            [pagesForColumn addObject:nextPage];
            id bottomLink = [nextPage linkForConnector:PCTemplateBottomConnector];
            nextPage = [self pageForLink:bottomLink];
        }
        
        PCColumn *column = [[PCColumn alloc] initWithPages:[pagesForColumn copy]];
        
        for (PCPage *page in pagesForColumn)
        {
            [page setColumn:column];
        }
        
        [firstColumnPage setColumn:column];
        [self.columns addObject:column];
        
        
        id rightLink = [firstColumnPage linkForConnector:PCTemplateRightConnector];
        firstColumnPage = [self pageForLink:rightLink];
    }
}

- (PCPage*) pgeWithNoLeftOrTopConnectors
{
    for (PCPage* page in self.pages)
    {
        if([page linkForConnector:PCTemplateLeftConnector] || [page linkForConnector:PCTemplateTopConnector])
        {
            continue;
        }
        else
        {
            return page;
        }
    }
    return nil;
}

@end
