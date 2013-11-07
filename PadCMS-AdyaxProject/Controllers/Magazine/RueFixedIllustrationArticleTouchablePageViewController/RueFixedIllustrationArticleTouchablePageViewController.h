//
//  RueFixedIllustrationArticleTouchablePageViewController.h
//  Pad CMS
//
//  Created by Maksym Martyniuk on 11/1/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCFixedIllustrationArticleViewController.h"

@class RueGalleryWithOverlaysViewController;

@interface RueFixedIllustrationArticleTouchablePageViewController : PCFixedIllustrationArticleViewController
{
//    RueGalleryWithOverlaysViewController *galleryWithOverlaysViewController;
    UIDeviceOrientation currentMagazineOrientation;
    BOOL galleryIsShowed;
}

@property (nonatomic,strong) RueGalleryWithOverlaysViewController* galleryWithOverlaysViewController;

@end
