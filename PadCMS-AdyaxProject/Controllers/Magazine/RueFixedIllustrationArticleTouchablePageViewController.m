//
//  RueFixedIllustrationArticleTouchablePageViewController.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 11/1/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "RueFixedIllustrationArticleTouchablePageViewController.h"
#import "PCScrollView.h"

@implementation RueFixedIllustrationArticleTouchablePageViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    [self.articleView setScrollEnabled:( ! self.bodyViewController.view.hidden )];
}

- (void)tapAction:(id)sender
{
    [super tapAction:sender];
    [self.articleView setScrollEnabled:( ! self.bodyViewController.view.hidden )];
}


@end
