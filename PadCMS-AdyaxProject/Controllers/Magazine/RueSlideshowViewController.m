//
//  RueSlideshowViewController.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 11/12/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "RueSlideshowViewController.h"

@interface RueSlideshowViewController ()

@end

@implementation RueSlideshowViewController

- (void) loadFullView
{
    CGSize screenSize = [[UIScreen mainScreen]bounds].size;
    
    if(sliderRect.size.width > screenSize.width)
    {
        sliderRect.size.width = screenSize.width - sliderRect.origin.x;
    }
    
    [super loadFullView];
}





@end
