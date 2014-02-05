//
//  PCPage+NewTemplates.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 2/5/14.
//  Copyright (c) 2014 Adyax. All rights reserved.
//

#import "PCPage+NewTemplates.h"
#import "PCPageTemplatesPool.h"
#import "PCPageElemetTypes.h"

@interface PCPage ()
{
    NSArray* _primaryElements;
    NSArray* _secondaryElements;
}
@end

@implementation PCPage (NewTemplates)

- (NSArray *) primaryElements
{
    if (_primaryElements) return _primaryElements;
    NSMutableArray* array = [[NSMutableArray alloc] init];
    
    if (self.pageTemplate.identifier == PCCoverPageTemplate)
    {
        PCPageElement* background = [self firstElementForType:PCPageElementTypeBackground];
        if (background) [array addObject:background];
        PCPageElement* body = [self firstElementForType:PCPageElementTypeBody];
        if (body) [array addObject:body];
        PCPageElement* advert = [self firstElementForType:PCPageElementTypeAdvert];
        if (advert) [array addObject:advert];
        
    }
    else if (self.pageTemplate.identifier == PCSimplePageTemplate)
    {
        PCPageElement* body = [self firstElementForType:PCPageElementTypeBody];
        if (body) [array addObject:body];
    }
    else if (self.pageTemplate.identifier == PCBasicArticlePageTemplate || self.pageTemplate.identifier == PCBasicArticleWithGifsPageTemplate)
    {
        PCPageElement* body = [self firstElementForType:PCPageElementTypeBody];
        if (body) [array addObject:body];
    }
    else if ((self.pageTemplate.identifier == PCScrollingPageTemplate) || (self.pageTemplate.identifier == PCHorizontalScrollingPageTemplate))
    {
        PCPageElement* background = [self firstElementForType:PCPageElementTypeBackground];
        if (background) [array addObject:background];
        PCPageElement* scrollingPane = [self firstElementForType:PCPageElementTypeScrollingPane];
        if (scrollingPane) [array addObject:scrollingPane];
    }
    else if (self.pageTemplate.identifier == PCSlideshowPageTemplate)
    {
        PCPageElement* background = [self firstElementForType:PCPageElementTypeBackground];
        if (background) [array addObject:background];
        PCPageElement* firstSlide = [self firstElementForType:PCPageElementTypeSlide];
        if (firstSlide) [array addObject:firstSlide];
    }
    else if ((self.pageTemplate.identifier == PCSlidersBasedMiniArticlesTopPageTemplate)||
             (self.pageTemplate.identifier == PCSlidersBasedMiniArticlesHorizontalPageTemplate)||
             (self.pageTemplate.identifier == PCSlidersBasedMiniArticlesVerticalPageTemplate))
    {
        PCPageElement* background = [self firstElementForType:PCPageElementTypeBackground];
        if (background) [array addObject:background];
        NSArray* miniArticles = [self elementsForType:PCPageElementTypeMiniArticle];
        if (miniArticles) [array addObjectsFromArray:miniArticles];
    }
    else if (self.pageTemplate.identifier == PCGalleryFlashBulletInteractivePageTemplate)
    {
        PCPageElement* background = [self firstElementForType:PCPageElementTypeBackground];
        if (background) [array addObject:background];
        PCPageElement* scrollingPane = [self firstElementForType:PCPageElementTypeScrollingPane];
        if (scrollingPane) [array addObject:scrollingPane];
        
    }
    else if (self.pageTemplate.identifier == PCFixedIllustrationArticleTouchablePageTemplate)
    {
        PCPageElement* background = [self firstElementForType:PCPageElementTypeBackground];
        if (background) [array addObject:background];
        PCPageElement* body = [self firstElementForType:PCPageElementTypeBody];
        if (body) [array addObject:body];
    }
	else if (self.pageTemplate.identifier == PCInteractiveBulletsPageTemplate)
    {
        PCPageElement* background = [self firstElementForType:PCPageElementTypeBackground];
        if (background) [array addObject:background];
        NSArray* miniArticles = [self elementsForType:PCPageElementTypeMiniArticle];
        if (miniArticles) [array addObjectsFromArray:miniArticles];
    }
    else if (self.pageTemplate.identifier == PCHTMLPageTemplate)
    {
        PCPageElement* body = [self firstElementForType:PCPageElementTypeBody];
        if (body) [array addObject:body];
        NSArray* html = [self elementsForType:PCPageElementTypeHtml];
        if (html) [array addObjectsFromArray:html];
        
    }
    else if (self.pageTemplate.identifier == PC3DPageTemplate)
    {
        PCPageElement *background = [self firstElementForType:PCPageElementTypeBackground];
        if (background != nil)
        {
            [array addObject:background];
        }
        
        PCPageElement *graphics = [self firstElementForType:PCPageElementType3D];
        if (graphics != nil)
        {
            [array addObject:graphics];
        }
    }
	
    _primaryElements = [[NSArray alloc] initWithArray:array];
    
    return _primaryElements;
}

- (NSArray *) secondaryElements
{
    if (_secondaryElements) return _secondaryElements;
    NSMutableArray* array = [[NSMutableArray alloc] init];
    
    if (self.pageTemplate.identifier == PCCoverPageTemplate)
    {
        
    }
    else if (self.pageTemplate.identifier == PCSimplePageTemplate)
    {
        
    }
    else if (self.pageTemplate.identifier == PCBasicArticlePageTemplate || self.pageTemplate.identifier == PCBasicArticleWithGifsPageTemplate)
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
    
    NSMutableArray* soundElements = [NSMutableArray arrayWithArray:[self elementsForType:PCPageElementTypeSound]];
    if (soundElements)
    {
        [array addObjectsFromArray:soundElements];
    }
    
    _secondaryElements = [[NSArray alloc] initWithArray:array];
    
    return _secondaryElements;
}

@end
