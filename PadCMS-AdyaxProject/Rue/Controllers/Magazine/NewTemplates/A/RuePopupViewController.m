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
#import "RuePDFActiveZones.h"

@interface RuePopupViewController ()

@property (nonatomic, strong) PCPageElement* pageElement;
@property (nonatomic, assign) int index;
@property (nonatomic, assign) CGRect popupRect;

@property (nonatomic, strong) UIImageView* imageView;

@end

@implementation RuePopupViewController

+ (id) popupControllerWithIndex:(int)index forElement:(PCPageElement*)element withFrame:(CGRect)frame onScrollView:(UIScrollView*)scroll
{
    RuePopupViewController* controller = [[self alloc]initWithElement:element index:index];
    controller.popupRect = frame;
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
    
    self.view.frame = self.popupRect;
    
    self.view.backgroundColor = [UIColor clearColor];
    
    self.imageView = [[UIImageView alloc]initWithFrame:self.view.bounds];
    //self.imageView.backgroundColor = [UIColor blueColor];
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

- (void) load
{
    
}

- (void) unload
{
    
}

- (void) loadImage
{
    
}

- (void) unloadImage
{
    
}

@end
