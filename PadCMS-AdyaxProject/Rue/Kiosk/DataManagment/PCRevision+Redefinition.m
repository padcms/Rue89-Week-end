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
#import "PCPathHelper.h"
#import "PCConfig.h"

#define PCRevisionCoverImagePlaceholderName @"application-cover-placeholder.jpg"
#define PCRevisionCoverImageFileName @"cover.jpg"

@implementation PCRevision (Redefinition)

+ (void) load
{
    Method oldUpdateColumnsMethod = class_getInstanceMethod([PCRevision class], @selector(updateColumns));
    Method newUpdateColumnsMethod = class_getInstanceMethod([PCRevision class], @selector(updateColumnsRedefined));
    
    Method oldInitWithParameters = class_getInstanceMethod([PCRevision class], @selector(initWithParameters:rootDirectory:backEndURL:));
    Method newInitWithParameters = class_getInstanceMethod([PCRevision class], @selector(initWithParametersAdvanced:rootDirectory:backEndURL:));
    
    method_exchangeImplementations(oldUpdateColumnsMethod, newUpdateColumnsMethod);
    method_exchangeImplementations(oldInitWithParameters, newInitWithParameters);
}

- (id)initWithParametersAdvanced:(NSDictionary *)parameters
           rootDirectory:(NSString *)rootDirectory
              backEndURL:(NSURL *)backEndURL
{
    self = [self initWithParametersAdvanced:parameters rootDirectory:rootDirectory backEndURL:backEndURL];
    
    if (self)
    {
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setFormatterBehavior:NSDateFormatterBehavior10_4];
        [df setDateFormat:@"yyyy-MM-dd"];
        NSString *strDate = [parameters objectForKey:PCJSONRevisionRevisionCreatedKey];
        NSRange range = [strDate rangeOfString:@"T"];
        if(range.length)
        {
            strDate = [strDate substringToIndex:range.location];
        }
        self.createDate = [df dateFromString:strDate];
    }
    
    return self;
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

- (UIImage *)coverImage
{
    NSString *coverImagePath = [self.contentDirectory stringByAppendingPathComponent:PCRevisionCoverImageFileName];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:coverImagePath])
    {
        return [UIImage imageWithContentsOfFile:coverImagePath];
    }
    else if (self.coverImageListURL != nil)
    {
        
#warning - TEMPORARY RUE PERFORMANCE FIX, should be enabled for old projects like AIR
        //        NSURL *serverURL = _backEndURL != nil ? _backEndURL : [PCConfig serverURL] ;
        //        NSURL *fullCoverImageURL = [NSURL URLWithString:_coverImageListURL.absoluteString relativeToURL:serverURL];
        //        NSData *imageData = [NSData dataWithContentsOfURL:fullCoverImageURL];
        NSData *imageData = nil;
        
        UIImage *image = [UIImage imageWithData:imageData];
        
        if (image != nil)
        {
            [PCPathHelper createDirectoryIfNotExists:self.contentDirectory];
            
            [imageData writeToFile:coverImagePath atomically:YES];
            
            return [UIImage imageWithContentsOfFile:coverImagePath];
        }
    }
    
    return [UIImage imageNamed:PCRevisionCoverImagePlaceholderName];
}

@end