//
//  RueSlideViewController.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 11/29/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "RueSlideViewController.h"

@interface RueSlideViewController ()

@property (nonatomic, copy) NSString* resource;
@property (nonatomic, strong) UIImageView* imageView;

@end

@implementation RueSlideViewController

- (id) initWithResource:(NSString*)resource
{
    self = [super init];
    if(self)
    {
        self.resource = resource;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.autoresizesSubviews = YES;
    self.view.backgroundColor = [UIColor clearColor];
    
    self.imageView = [[UIImageView alloc]initWithFrame:self.view.bounds];
    self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:self.imageView];
}

- (void) unloadView
{
    self.imageView.image = nil;
}

- (void) loadFullViewImmediate
{
    NSString *fullResourcePath = self.resource;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        UIImage *image = [UIImage imageWithContentsOfFile:fullResourcePath];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.imageView setImage:image];
        });
    });
}

@end
