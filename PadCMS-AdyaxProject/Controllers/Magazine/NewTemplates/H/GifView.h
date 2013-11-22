//
//  GifView.h
//  Pad CMS
//
//  Created by Maksym Martyniuk on 11/22/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PCPageElement;

@interface GifView : UIWebView

+ (id) gifViewForElement:(PCPageElement*)element;

- (void) startShowing;

- (void) stopShowing;

@end
