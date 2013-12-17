//
//  PublisherPasswordAlertView.h
//  Pad CMS
//
//  Created by Maksym Martyniuk on 11/26/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PublisherPasswordAlertView : UIAlertView

- (id) initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle confirmButtonTitle:(NSString *)okButton;

- (BOOL) hasText;

- (NSString*) text;

@end
