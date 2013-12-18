//
//  PCPage+VideoDownloading.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 12/18/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCPage.h"
#import "PCPageTemplatesPool.h"

@interface PCPage ()
{
    NSArray* _secondaryElements;
}
@end

@implementation PCPage (VideoDownloading)

-(NSArray *)secondaryElements
{
    if (_secondaryElements) return _secondaryElements;
    NSMutableArray* array = [[NSMutableArray alloc] init];
    
    if (self.pageTemplate.identifier == PCCoverPageTemplate)
    {
        
    }
    else if (self.pageTemplate.identifier == PCSimplePageTemplate)
    {
        
    }
    else if (self.pageTemplate.identifier == PCBasicArticlePageTemplate)
    {
        NSArray* galleryElements = [self elementsForType:PCPageElementTypeGallery];
        if (galleryElements) [array addObjectsFromArray:galleryElements];
    }
    else if ((self.pageTemplate.identifier == PCScrollingPageTemplate) || (self.pageTemplate.identifier == PCHorizontalScrollingPageTemplate))
    {
        NSArray* galleryElements = [self elementsForType:PCPageElementTypeGallery];
        if (galleryElements) [array addObjectsFromArray:galleryElements];
        
    }
    else if (self.pageTemplate.identifier == PCSlideshowPageTemplate)
    {
        NSArray* slides = [self elementsForType:PCPageElementTypeSlide];
        if ([slides count] > 1) [array addObjectsFromArray:[slides objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, [slides count]-1)]]];
    }
    else if ((self.pageTemplate.identifier == PCSlidersBasedMiniArticlesTopPageTemplate)||
             (self.pageTemplate.identifier == PCSlidersBasedMiniArticlesHorizontalPageTemplate)||
             (self.pageTemplate.identifier == PCSlidersBasedMiniArticlesVerticalPageTemplate))
    {
        NSArray* miniArticles = [self elementsForType:PCPageElementTypeMiniArticle];
        if (miniArticles) if ([miniArticles count] > 1) [array addObjectsFromArray:[miniArticles objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, [miniArticles count]-1)]]];
    }
    else if (self.pageTemplate.identifier == PCGalleryFlashBulletInteractivePageTemplate)
    {
        NSArray* galleryElements = [self elementsForType:PCPageElementTypeGallery];
        if (galleryElements) [array addObjectsFromArray:galleryElements];
        NSArray* popupsElements = [self elementsForType:PCPageElementTypePopup];
        if (popupsElements) [array addObjectsFromArray:popupsElements];
    }
    else if (self.pageTemplate.identifier == PCFixedIllustrationArticleTouchablePageTemplate)
    {
        NSArray* galleryElements = [self elementsForType:PCPageElementTypeGallery];
        if (galleryElements) [array addObjectsFromArray:galleryElements];
        NSArray* popupsElements = [self elementsForType:PCPageElementTypePopup];
        if (popupsElements) [array addObjectsFromArray:popupsElements];
    }
    else if (self.pageTemplate.identifier == PCInteractiveBulletsPageTemplate)
    {
        NSArray* miniArticles = [self elementsForType:PCPageElementTypeMiniArticle];
        if (miniArticles) if ([miniArticles count] > 1) [array addObjectsFromArray:[miniArticles objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, [miniArticles count]-1)]]];
    }
    else if (self.pageTemplate.identifier == PCHTMLPageTemplate)
    {
        
    }
    
    NSMutableArray* videoElements = [NSMutableArray arrayWithArray:[self elementsForType:PCPageElementTypeVideo]];
    if (videoElements)
    {
        NSString* startVideoResource = self.revision.startVideo;
        if (startVideoResource && ![startVideoResource isEqualToString:@""])
        {
            for (int i = 0; i < videoElements.count; ++i)
            {
                PCPageElement* element = [videoElements objectAtIndex:i];
                
                if(element.resource && [element.resource isEqualToString:startVideoResource])
                {
                    [videoElements removeObjectAtIndex:i];
                    break;
                }
            }
        }
        
        [array addObjectsFromArray:videoElements];
        
    }
    
    _secondaryElements = [[NSArray alloc] initWithArray:array];
    [array release];
    
    return _secondaryElements;
    
}

@end
