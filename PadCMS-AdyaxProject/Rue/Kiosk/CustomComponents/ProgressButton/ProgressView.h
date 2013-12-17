//
//  ProgressView.h
//  Pad CMS
//
//  Created by Maksym Martyniuk on 10/10/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProgressView : UIView

@property (nonatomic, assign) float progress;
@property(nonatomic, strong) UIColor* progressTintColor;
@property(nonatomic, strong) UIColor* trackTintColor;

@end
