//
//  RuePopupViewController.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 11/25/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "RuePopupViewController.h"
#import "PCPageElement.h"
#import "PCPage.h"
#import "PCPageActiveZone.h"

@interface RuePopupViewController ()

@property (nonatomic, strong) PCPageElement* pageElement;
@property (nonatomic, strong) UIImageView* imageView;

@property (nonatomic, assign) int index;

@end

@implementation RuePopupViewController

+ (id) popupControllerWithIndex:(int)index forElement:(PCPageElement*)element
{
    RuePopupViewController* controller = [[self alloc]initWithElement:element index:index];
    return controller;
}

- (id) initWithElement:(PCPageElement*)element index:(int)index
{
    self = [super init];
    if(self)
    {
        self.pageElement = element;
        self.index = index;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect elementRect = [self frameForPopupElement:self.pageElement];
    
    self.view.frame = elementRect;
    
    self.view.backgroundColor = [UIColor clearColor];
    
    self.imageView = [[UIImageView alloc]initWithFrame:self.view.bounds];
    self.imageView.backgroundColor = [UIColor blueColor];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [self.view addSubview:self.imageView];
    
    NSString *fullResourcePath = [self.pageElement.page.revision.contentDirectory stringByAppendingPathComponent:self.pageElement.resource];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        UIImage *image = [UIImage imageWithContentsOfFile:fullResourcePath];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.imageView setImage:image];
        });
        
        
    });
    
    self.view.userInteractionEnabled = NO;
    
    self.view.hidden = YES;
}

- (BOOL) isPresented
{
    return (! self.view.hidden);
}

- (CGRect) frameForPopupElement:(PCPageElement*)element
{
    if(element.dataRects.count > 0)
    {
        NSArray* keys = element.dataRects.allKeys;
        NSString* rectString = [element.dataRects valueForKey:keys.lastObject];
        return CGRectFromString(rectString);
    }
    else
    {
        for (PCPageElement* element in self.pageElement.page.elements)
        {
            for (PCPageActiveZone* pdfActiveZone in element.activeZones)
            {
                if ([pdfActiveZone.URL hasPrefix:PCPDFActiveZoneActionButton])
                {
                    NSString* additional = [pdfActiveZone.URL lastPathComponent];
                    int zoneIndex = [additional intValue];
                    if(zoneIndex == self.index + 1)
                    {
                        return pdfActiveZone.rect;
                    }
                    
                }
            }
        }
    }
    return CGRectZero;
}

@end
