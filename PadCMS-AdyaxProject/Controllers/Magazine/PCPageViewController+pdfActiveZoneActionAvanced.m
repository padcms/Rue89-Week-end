//
//  PCPageViewController+pdfActiveZoneActionAvanced.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 10/30/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCPageViewController.h"
#import "PCSliderBasedMiniArticleViewController.h"
#import "PCPDFActiveZones.h"
#import "PCPageElemetTypes.h"
#import "objc/runtime.h"
#import "RueBrowserViewController.h"
#import "PCScrollView.h"

#import "PCPageViewController+IsPresented.h"
#import "UIView+EasyFrame.h"

@interface PCPageViewController ()

//- (void)hideVideoWebView;
- (void)showVideoWebView: (NSString *)videoWebViewURL inRect: (CGRect)videoWebViewRect;
- (void) showGalleryWithID:(NSInteger)ID initialPhotoID:(NSInteger)photoID;

- (void) hideSubviews;

@end

@implementation PCPageViewController (pdfActiveZoneActionAvanced)

+ (void) load
{
    Method prevMethod = class_getInstanceMethod([PCPageViewController class], @selector(pdfActiveZoneAction:));
    Method newMethod = class_getInstanceMethod([PCPageViewController class], @selector(pdfActiveZoneActionAdvanced:));
    
    method_exchangeImplementations(prevMethod, newMethod);
}

-(BOOL)pdfActiveZoneActionAdvanced:(PCPageActiveZone*)activeZone
{
    if ([activeZone.URL hasPrefix:PCPDFActiveZoneNavigation])
    {
        NSString* mashinName = [activeZone.URL lastPathComponent];
        NSArray* components = [mashinName componentsSeparatedByString:@"#"];
        NSString* addeditional = nil;
        if ([components count] > 1)
        {
            mashinName = [components objectAtIndex:0];
            addeditional = [components objectAtIndex:1];
        }
        
        PCPage* targetPage = [page.revision pageWithMachineName:mashinName];
        
        if (targetPage)
        {
            PCPageViewController* pageController = [magazineViewController showPage:targetPage];
            if ([pageController isKindOfClass:[PCSliderBasedMiniArticleViewController class]])
            {
                [(PCSliderBasedMiniArticleViewController*)pageController showArticleAtIndex:[addeditional integerValue] - 1];
                return YES;
            }
        }
    }
    if ([activeZone.URL hasPrefix:PCPDFActiveZoneActionVideo])
    {
        if ([self.page hasPageActiveZonesOfType:PCPDFActiveZoneVideo])
        {
            if (videoWebView && videoWebView.superview)
                [self hideVideoWebView];
            else
            {
                CGRect videoRect = [[UIScreen mainScreen] bounds];
                PCPageElementVideo *videoElement = (PCPageElementVideo*)[self.page firstElementForType:PCPageElementTypeVideo];
                [self showVideoWebView:videoElement.stream inRect:videoRect];
            }
            return YES;
        }
        NSArray* videoElements = [page elementsForType:PCPageElementTypeVideo];
        PCPageElementVideo* video = nil;
        if ([videoElements count]>1)
        {
            NSArray* comps = [activeZone.URL componentsSeparatedByString:PCPDFActiveZoneActionVideo];
            if (comps&&[comps count]>1)
            {
                
                NSString* num = [comps objectAtIndex:1];
                int number = [num intValue]-1;
                video = [videoElements objectAtIndex:number];
            }
            else
            {
                video = [videoElements objectAtIndex:0];
            }
        }
        else
        {
            if ([videoElements count]>0)
                video = [videoElements objectAtIndex:0];
        }
        
        if (video)
        {
            if (video.stream)
                [self showVideo:video.stream];
            
            if (video.resource)
                [self showVideo:[page.revision.contentDirectory stringByAppendingPathComponent:video.resource]];
            
            return YES;
        }
    }
    
    if ([activeZone.URL hasPrefix:PCPDFActiveZoneActionPhotos])
    {
        NSString *url = activeZone.URL;
        NSInteger photoID = [[url lastPathComponent] integerValue];
        NSInteger galleryID = [[[url stringByDeletingLastPathComponent] lastPathComponent] integerValue];
        if (galleryID == 0)
        {
            galleryID = photoID;
            photoID = 0;
        }
        NSLog(@"url - %@, gallery - %d, photo - %d", activeZone.URL, galleryID, photoID);
        [self showGalleryWithID:galleryID initialPhotoID:photoID];
        return YES;
    }
    
    if ([activeZone.URL hasPrefix:@"http://"])
    {
        if ([[activeZone.URL pathExtension] isEqualToString:@"mp4"]||[[activeZone.URL pathExtension] isEqualToString:@"avi"])
        {
            [self hideVideoWebView];
            [self showVideoWebView:activeZone.URL inRectAdvanced:[self activeZoneRectForType:activeZone.URL]];
            //[self showVideo:activeZone.URL];
            return YES;
        }
        
        else if ([activeZone.URL hasPrefix:@"http://youtube.com"] || [activeZone.URL hasPrefix:@"http://www.youtube.com"] ||
                 [activeZone.URL hasPrefix:@"http://youtu.be"] || [activeZone.URL hasPrefix:@"http://www.youtu.be"] ||
                 [activeZone.URL hasPrefix:@"http://dailymotion.com"] || [activeZone.URL hasPrefix:@"http://www.dailymotion.com"] ||
                 [activeZone.URL hasPrefix:@"http://vimeo.com"] || [activeZone.URL hasPrefix:@"http://www.vimeo.com"])
        {
//            CGRect videoRect = [self activeZoneRectForType:PCPDFActiveZoneVideo];
//            [self showVideoWebView:activeZone.URL inRect:videoRect];
            [self hideVideoWebView];
            [self showVideoWebView:activeZone.URL inRectAdvanced:[self activeZoneRectForType:activeZone.URL]];
            return YES;
        }
        
        else
        {
            if (![[UIApplication sharedApplication] openURL:[NSURL URLWithString:activeZone.URL]])
            {
                NSLog(@"Failed to open url:%@",[activeZone.URL description]);
            }
        }
    }
    return NO;
}

- (void)showVideoWebView: (NSString *)videoWebViewURL inRectAdvanced: (CGRect)videoWebViewRect
{
    NSLog(@"URL playing : %@", videoWebViewURL);
    CGRect videoRect = videoWebViewRect;
    if (CGRectEqualToRect(videoRect, CGRectZero))
    {
        videoRect = [[UIScreen mainScreen] bounds];
    }
    
    [self hideVideoWebView];
    
    webBrowserViewController = [[RueBrowserViewController alloc] init];
    webBrowserViewController.videoRect = videoRect;
    
    ((RueBrowserViewController*)webBrowserViewController).mainScrollView = self.mainScrollView;
    ((RueBrowserViewController*)webBrowserViewController).pageView = self.view;
    
    [self.mainScrollView addSubview:webBrowserViewController.view];
    
    if (self.page.pageTemplate ==
        [[PCPageTemplatesPool templatesPool] templateForId:PCFixedIllustrationArticleTouchablePageTemplate] || self.page.pageTemplate.identifier == PCBasicArticlePageTemplate)
    {
        [self changeVideoLayout:YES]; //bodyViewController.view.hidden];
    }
    [webBrowserViewController presentURL:videoWebViewURL];
}

- (void)hideVideoWebView
{
    if (webBrowserViewController)
    {
        [(RueBrowserViewController*)webBrowserViewController stop];
        [webBrowserViewController.view removeFromSuperview];
        webBrowserViewController = nil;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    if([self isPresentedPage] == NO)
    {
        [(RueBrowserViewController*)webBrowserViewController stop];
        [self hideSubviews];
        [super viewWillDisappear:animated];
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint point = [gestureRecognizer locationInView:self.mainScrollView];
    NSArray* actions = [self activeZonesAtPoint:point];
    if (actions&&[actions count]>0)
    {
        if(webBrowserViewController && [(RueBrowserViewController*)webBrowserViewController containsPoint:[gestureRecognizer locationInView:webBrowserViewController.view]])
        {
            return NO;
        }
        return YES;
    }
    
    return NO;
}

- (void) createGalleryButton
{
    
}

@end
