//
//  PCKioskPopupView.h
//  Pad CMS
//
//  Created by tar on 22.08.13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PCKioskPopupView : UIView

- (id)initWithSize:(CGSize)size viewToShowIn:(UIView *)view;

- (void)show;
- (void)hide;

@end
