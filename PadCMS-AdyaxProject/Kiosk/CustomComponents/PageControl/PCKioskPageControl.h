//
//  PCKioskPageControl.h
//  Pad CMS
//
//  Created by tar on 28.08.13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PCKioskPageControl : UIView

@property (nonatomic) NSInteger currentPage;
@property (nonatomic) NSInteger pagesCount;

+ (PCKioskPageControl *)pageControl;

@end
