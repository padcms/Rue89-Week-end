//
//  PCPageElementManager+RuePageElementManager.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 11/26/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCPageElementManager.h"
#import "PCData.h"

#import "RuePageElementBackground.h"

@implementation PCPageElementManager (RuePageElementManager)

- (void) initializeBaseElements
{
    [self registerPageElementClass:[RuePageElementBackground class] forElementType:PCPageElementTypeBackground];
    [self registerPageElementClass:[PCPageElement class] forElementType:PCPageElementTypeSound];
    [self registerPageElementClass:[PCPageElement class] forElementType:PCPageElementTypePopup];
    
    [self registerPageElementClass:[PCPageElementBody class] forElementType:PCPageElementTypeBody];
    [self registerPageElementClass:[PCPageElementVideo class] forElementType:PCPageElementTypeVideo];
    [self registerPageElementClass:[PCPageElementAdvert class] forElementType:PCPageElementTypeAdvert];
    [self registerPageElementClass:[PCPageElementScrollingPane class] forElementType:PCPageElementTypeScrollingPane];
    [self registerPageElementClass:[PCPageElementMiniArticle class] forElementType:PCPageElementTypeMiniArticle];
    [self registerPageElementClass:[PCPageElementSlide class] forElementType:PCPageElementTypeSlide];
    [self registerPageElementClass:[PCPageElementHtml class] forElementType:PCPageElementTypeHtml];
    [self registerPageElementClass:[PCPageElementHtml5 class] forElementType:PCPageElementTypeHtml5];
    [self registerPageElementClass:[PCPageElementDragAndDrop class] forElementType:PCPageElementTypeDragAndDrop];
    [self registerPageElementClass:[PCPageElement class] forElementType:PCPageElementType3D];
    [self registerPageElementClass:[PCPageElementGallery class] forElementType:PCPageElementTypeGallery];
}

@end
