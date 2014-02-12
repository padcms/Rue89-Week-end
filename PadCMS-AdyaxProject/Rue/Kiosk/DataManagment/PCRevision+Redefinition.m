//
//  PCRevision+Redefinition.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 10/24/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCRevision+DataOfDownload.h"
#import <objc/runtime.h>
#import "PCPage.h"
#import "PCColumn.h"
#import "PCPathHelper.h"
#import "PCConfig.h"
#import "PCJSONKeys.h"
#import "PCPageElemetTypes.h"
#import "PCPageElementMiniArticle.h"
#import "PCTocItem.h"
#import "RueResourceShredder.h"
#import "PCPage+NewTemplates.h"

#define PCRevisionCoverImagePlaceholderName @"application-cover-placeholder.jpg"
#define PCRevisionCoverImageFileName @"cover.jpg"

@implementation PCRevision (Redefinition)

+ (void) load
{
    Method oldUpdateColumnsMethod = class_getInstanceMethod([PCRevision class], @selector(updateColumns));
    Method newUpdateColumnsMethod = class_getInstanceMethod([PCRevision class], @selector(updateColumnsRedefined));
    
    Method oldInitWithParameters = class_getInstanceMethod([PCRevision class], @selector(initWithParameters:rootDirectory:backEndURL:));
    Method newInitWithParameters = class_getInstanceMethod([PCRevision class], @selector(initWithParametersAdvanced:rootDirectory:backEndURL:));
    
    Method oldIsDownloadedMethod = class_getInstanceMethod([PCRevision class], @selector(isDownloaded));
    Method newIsDownloadedMethod = class_getInstanceMethod([PCRevision class], @selector(isDownloadedAdvanced));
    
    method_exchangeImplementations(oldUpdateColumnsMethod, newUpdateColumnsMethod);
    method_exchangeImplementations(oldInitWithParameters, newInitWithParameters);
    method_exchangeImplementations(oldIsDownloadedMethod, newIsDownloadedMethod);
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
        
//#warning - TEMPORARY RUE PERFORMANCE FIX, should be enabled for old projects like AIR
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

- (BOOL) isDownloadedAdvanced
{
    BOOL isDatabaseDownloaded = [self isDownloadedAdvanced];
    
    if(isDatabaseDownloaded)
    {
        if(self.isContentDownloading)
        {
            return YES;
        }
        else
        {
            if([self isAllFilesDownloaded] && [self isAllResourcesShredded])
            {
                return YES;
            }
            else
            {
                return NO;
            }
        }
    }
    else
    {
        return NO;
    }
}

- (BOOL) isAllResourcesShredded
{
    NSArray* resources = [self allShreddingResources];
    
    for (NSString* resource in resources)
    {
        if([RueResourceShredder allPeacesExistsForResource:resource])
        {
            continue;
        }
        else
        {
            return NO;
        }
    }
    
    return YES;
}

- (BOOL) isAllFilesDownloaded
{
    NSArray* allFiles = [self allDownloadingResources];
    
    for (NSString* resource in allFiles)
    {
        if([[NSFileManager defaultManager]fileExistsAtPath:[self.contentDirectory stringByAppendingPathComponent:resource]])
        {
            continue;
        }
        else
        {
            return NO;
        }
    }
    
    return YES;
}

- (NSArray*) allDownloadingResources
{
    NSMutableArray* resources = [[NSMutableArray alloc]init];
    
    //TocDownloading
    
    for (PCTocItem* item in self.toc)
    {
        if(item.thumbStripe)
            [resources addObject:item.thumbStripe];
        if(item.thumbSummary)
            [resources addObject:item.thumbSummary];
    }
    
    //HelpDownloading
    
	if(self.helpPages && [self.helpPages count] > 0)
    {
        [self.helpPages enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [resources addObject:obj];
        }];
    }
    
    //PortraitPagesDownloading
    
    for (PCColumn* column in self.columns)
    {
        for (PCPage* page in column.pages)
        {
            BOOL isMiniArticleMet = NO;
            for (PCPageElement* element in page.primaryElements)
            {
                if ([element isKindOfClass:[PCPageElementMiniArticle class]])
                {
                    if (!isMiniArticleMet)
                    {
                        if(element.resource)
                            [resources addObject:element.resource];
                    }
                    isMiniArticleMet = YES;
                    PCPageElementMiniArticle* miniArticle = (PCPageElementMiniArticle*)element;
                    if(miniArticle.thumbnail)
                        [resources addObject:miniArticle.thumbnail];
                    if(miniArticle.thumbnailSelected)
                        [resources addObject:miniArticle.thumbnailSelected];
                }
                else
                {
                    if(element.resource)
                        [resources addObject:element.resource];
                }
            }
            for (PCPageElement* element in page.secondaryElements)
            {
                if(element.resource)
                    [resources addObject:element.resource];
            }
        }
    }
    
    //HorizontalTocDownload
    
	for (NSString* resource in [self.horisontalTocItems allValues])
    {
        [resources addObject:[@"/horisontal_toc_items" stringByAppendingPathComponent:resource]];
	}
    
    //HorizonalPagesDownload
    
	if (self.horizontalPages && [self.horizontalPages count] > 0)
    {
        [self.horizontalPages enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [resources addObject:obj];
        }];
    }
    
    
    return [NSArray arrayWithArray:resources];
}

- (NSArray*) allShreddingResources
{
    NSMutableArray* shreddingResources = [[NSMutableArray alloc]init];
    
    for (PCColumn* column in self.columns)
    {
        for (PCPage* page in column.pages)
        {
            if(page.pageTemplate.identifier == PCScrollingGalleryWithFixedMenuPageTemplate)
            {
                NSArray* galleryElements = [page elementsForType:PCPageElementTypeGallery];
                
                for (PCPageElement* element in galleryElements)
                {
                    if(element.size.height > [RueResourceShredder heightNoNeededToShred])
                    {
                        [shreddingResources addObject:[self.contentDirectory stringByAppendingPathComponent:element.resource]];
                    }
                }
            }
            else
            {
                NSArray* bodyElements = [page elementsForType:PCPageElementTypeBody];
                
                for (PCPageElement* element in bodyElements)
                {
                    if(element.size.height > [RueResourceShredder heightNoNeededToShred])
                    {
                        [shreddingResources addObject:[self.contentDirectory stringByAppendingPathComponent:element.resource]];
                    }
                }
            }
        }
    }
    
    return [NSArray arrayWithArray:shreddingResources];
}

@end
