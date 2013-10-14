//
//  PCLandscapeViewController+InterfaceOrientation.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 10/14/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCLandscapeViewController+InterfaceOrientation.h"

@implementation PCLandscapeViewController (InterfaceOrientation)

- (BOOL) shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeRight;
}

@end
