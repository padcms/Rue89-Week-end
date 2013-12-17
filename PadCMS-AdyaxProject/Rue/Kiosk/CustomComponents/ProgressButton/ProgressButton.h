//
//  ProgressButton.h
//  Pad CMS
//
//  Created by Maksym Martyniuk on 10/10/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProgressButton : UIButton

+ (ProgressButton*) progressButtonWithTitle:(NSString*)title;

- (void) setProgress:(float)progress;

- (void) showProgress;
- (void) hideProgress;

- (void) showPatience;
- (void) hidePatience;

@end
