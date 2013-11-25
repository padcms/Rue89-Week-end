//
//  RuePopupViewController.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 11/25/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "RuePopupViewController.h"
#import "PCPageElement.h"

@interface RuePopupViewController ()

@property (nonatomic, strong) PCPageElement* pageElement;
@property (nonatomic, strong) UIImageView* imageView;

@end

@implementation RuePopupViewController

+ (id) popupControllerForElement:(PCPageElement*)element
{
    RuePopupViewController* controller = [[self alloc]initWithElement:element];
    return controller;
}

- (id) initWithElement:(PCPageElement*)element
{
    self = [super init];
    if(self)
    {
        self.pageElement = element;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    self.imageView = [[UIImageView alloc]initWithFrame:self.view.bounds];
    self.imageView.backgroundColor = [UIColor clearColor];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    //self.imageView.image =
    
    [self.view addSubview:self.imageView];
    
    //    PCPageElement*popupElement = [popupsElements objectAtIndex:[popupIndex integerValue]];
    //    if (!popupElement.isComplete)
    //        [[NSNotificationCenter defaultCenter] postNotificationName:PCBoostPageNotification object:popupElement];
    //    NSString *fullResourcePath = [self.page.revision.contentDirectory stringByAppendingPathComponent:popupElement.resource];
    //    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
    //        if (popupElement.isComplete && [[NSFileManager defaultManager] fileExistsAtPath:fullResourcePath])
    //        {
    //            UIImage *image = [UIImage imageWithContentsOfFile:fullResourcePath];
    //            dispatch_async(dispatch_get_main_queue(), ^{
    //                [popupImageView setImage:image];
    //                popupImageView.hidden = NO;
    //            });
    //            
    //        }
    //    });
    
}

- (BOOL) isPresented
{
    return (! self.view.hidden);
}

@end
