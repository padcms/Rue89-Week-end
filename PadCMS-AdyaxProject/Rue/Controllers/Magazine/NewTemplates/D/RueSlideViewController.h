//
//  RueSlideViewController.h
//  Pad CMS
//
//  Created by Maksym Martyniuk on 11/29/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RueSlideViewController : UIViewController

- (id) initWithResource:(NSString*)resource;

- (void) unloadView;
- (void) loadFullViewImmediate;

@end
