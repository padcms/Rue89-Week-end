//
//  PCKioskPageControl.h
//  Pad CMS
//
//  Created by tar on 28.08.13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PCKioskPageControl;

@protocol PCKioskPageControlDelegate <NSObject>

- (void)kioskPageControl:(PCKioskPageControl *)pageControl didChangePage:(NSInteger)page;

@end


@interface PCKioskPageControl : UIView

@property (nonatomic) NSInteger currentPage;
@property (nonatomic) NSInteger pagesCount;
@property (nonatomic, weak) id<PCKioskPageControlDelegate> delegate;

+ (PCKioskPageControl *)pageControl;
+ (NSUInteger)subviewTag;

@end
