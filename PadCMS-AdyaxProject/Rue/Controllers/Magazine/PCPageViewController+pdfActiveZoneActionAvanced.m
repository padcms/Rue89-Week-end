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
    
    Method prevMethod2 = class_getInstanceMethod([PCPageViewController class], @selector(loadFullView));
    Method newMethod2 = class_getInstanceMethod([PCPageViewController class], @selector(loadFullViewAdvanced));
    
    method_exchangeImplementations(prevMethod, newMethod);
    method_exchangeImplementations(prevMethod2, newMethod2);
}

- (BOOL) pdfActiveZoneActionAdvanced:(PCPageActiveZone*)activeZone
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
        NSArray* videoElementsArray = [page elementsForType:PCPageElementTypeVideo];
        
        if(videoElementsArray.count > 0)
        {
            if(videoElementsArray.count == 1)
            {
                PCPageElementVideo *videoElement = (PCPageElementVideo*)[videoElementsArray objectAtIndex:0];
                CGRect videoRect = [self activeZoneRectForType:PCPDFActiveZoneVideo];
                if(CGRectEqualToRect(videoRect, CGRectZero))
                {
                    videoRect = [self activeZoneRectForType:activeZone.URL];
                }
                [self showVideoElement:videoElement inRect:videoRect];
            }
            else
            {
                videoElementsArray = [videoElementsArray sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"weight" ascending:YES],[NSSortDescriptor sortDescriptorWithKey:@"identifier" ascending:YES],nil]];
                
                int videoIndex = 0;
                
                NSArray* comps = [activeZone.URL componentsSeparatedByString:PCPDFActiveZoneActionVideo];
                if (comps && [comps count] > 1)
                {
                    NSString* num = [comps objectAtIndex:1];
                    videoIndex = [num intValue] - 1;
                }
                if(videoIndex >= videoElementsArray.count)
                {
                    videoIndex = videoIndex % videoElementsArray.count;
                }
                
                NSString* videoZoneType = [PCPDFActiveZoneVideo stringByAppendingFormat:@"%i", (videoIndex + 1)];
                CGRect videoRect = [self activeZoneRectForType:videoZoneType];
                if(CGRectEqualToRect(videoRect, CGRectZero))
                {
                    videoZoneType = [videoZoneType stringByAppendingString:@"/autoplay"];
                    videoRect = [self activeZoneRectForType:videoZoneType];
                    if(CGRectEqualToRect(videoRect, CGRectZero))
                    {
                        videoRect = [self activeZoneRectForType:activeZone.URL];
                    }
                }
                PCPageElementVideo *videoElement = (PCPageElementVideo*)[videoElementsArray objectAtIndex:videoIndex];
                
                [self showVideoElement:videoElement inRect:videoRect];
            }
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

- (void) showVideoWebView: (NSString *)videoWebViewURL inRectAdvanced: (CGRect)videoWebViewRect
{
    NSLog(@"URL playing : %@", videoWebViewURL);
    
    [self createWebBrowserViewWithFrame:videoWebViewRect];
    
    [webBrowserViewController presentURL:videoWebViewURL];
}

- (void) showVideoElement:(PCPageElementVideo*)element inRect:(CGRect)videoWebViewRect
{
    NSLog(@"URL playing : %@", element.resource);
    
    [self createWebBrowserViewWithFrame:videoWebViewRect];
    
    [(RueBrowserViewController*)webBrowserViewController presentElement:element ofPage:self.page];
}

- (void) createWebBrowserViewWithFrame:(CGRect)frame
{
    CGRect videoRect = frame;
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
}

- (void) hideVideoWebView
{
    if (webBrowserViewController)
    {
        [(RueBrowserViewController*)webBrowserViewController stop];
        [webBrowserViewController.view removeFromSuperview];
        webBrowserViewController = nil;
        [self.mainScrollView setNeedsLayout];
        [self.mainScrollView setNeedsDisplay];
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

- (void) loadFullViewAdvanced
{
	isLoaded = YES;
	//[self showHUD];
    [self.backgroundViewController loadFullViewImmediate];
    [self.bodyViewController loadFullViewImmediate];
    
    CGSize bodySize = self.bodyViewController.view.frame.size;
    
    [self.mainScrollView setContentSize:bodySize];
    
    if (self.isPresentedPage && [self.page hasPageActiveZonesOfType:PCPDFActiveZoneVideo])
    {
        if ([self.page hasPageActiveZonesOfType:PCPDFActiveZoneActionVideo] == NO)
        {
            CGRect videoRect = [self activeZoneRectForType:PCPDFActiveZoneVideo];
            PCPageElementVideo *videoElement = (PCPageElementVideo*)[self.page firstElementForType:PCPageElementTypeVideo];
            
            if (videoElement.stream || videoElement.resource)
            {
                [self showVideoElement:videoElement inRect:videoRect];
            }
        }
        else
        {
            for (PCPageElement* element in self.page.elements)
            {
                for (PCPageActiveZone* pdfActiveZone in element.activeZones)
                {
                    if ([pdfActiveZone.URL hasPrefix:PCPDFActiveZoneVideo] && [pdfActiveZone.URL hasSuffix:@"/autoplay"])
                    {
                        NSString* indexStr = [[pdfActiveZone.URL stringByReplacingOccurrencesOfString:PCPDFActiveZoneVideo withString:@""]stringByReplacingOccurrencesOfString:@"/autoplay" withString:@""];
                        int videoElementIndex = [indexStr intValue] - 1;
                        if(videoElementIndex >= 0)
                        {
                            NSArray* videoElementsArray = [page elementsForType:PCPageElementTypeVideo];
                            videoElementsArray = [videoElementsArray sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"weight" ascending:YES],[NSSortDescriptor sortDescriptorWithKey:@"identifier" ascending:YES],nil]];
                            
                            if(videoElementIndex < videoElementsArray.count)
                            {
                                CGRect videoRect = [self activeZoneRectForType:pdfActiveZone.URL];
                                if(CGRectEqualToRect(videoRect, CGRectZero) == NO)
                                {
                                    PCPageElementVideo *videoElement = (PCPageElementVideo*)[videoElementsArray objectAtIndex:videoElementIndex];
                                    [self showVideoElement:videoElement inRect:videoRect];
                                }
                            }
                        }
                        break;
                    }
                }
            }
        }
    }
    
    //[self createGalleryButton];
    
//    if (self.galleryButton != nil) {
//        [self.galleryButton.superview bringSubviewToFront:self.galleryButton];
//    }
    /*
    for (PCPageElement* element in self.page.elements)
    {
        [element.dataRects enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            CGRect rect = CGRectFromString(obj);
            if (!CGRectEqualToRect(rect, CGRectZero))
            {
                CGSize pageSize = [self.columnViewController pageSizeForViewController:self];
                float scale = pageSize.width/element.size.width;
                rect.size.width *= scale;
                rect.size.height *= scale;
                rect.origin.x *= scale;
                rect.origin.y *= scale;
                rect.origin.y = element.size.height*scale - rect.origin.y - rect.size.height;
                
                UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
                btn.userInteractionEnabled = NO;
                btn.backgroundColor = [UIColor greenColor];//colorWithRed:((float)rand())/255.0 green:((float)rand())/255.0 blue:((float)rand())/255.0 alpha:1];
                btn.alpha = 0.3;
                btn.frame = rect;
                
                
                btn.titleLabel.adjustsFontSizeToFitWidth = YES;
                btn.titleLabel.minimumScaleFactor = 0.01;
                
                [btn setTitle:key forState:UIControlStateNormal];
                [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [self.mainScrollView addSubview:btn];
            }
        }];
    }*/
}

@end
