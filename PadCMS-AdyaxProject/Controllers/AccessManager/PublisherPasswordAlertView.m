//
//  PublisherPasswordAlertView.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 11/26/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PublisherPasswordAlertView.h"

@implementation PublisherPasswordAlertView

- (id) initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle confirmButtonTitle:(NSString *)okButtonTitle
{
    self = [super initWithTitle:@"Publisher password." message:message delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:okButtonTitle, nil];
    if(self)
    {
        self.alertViewStyle = UIAlertViewStyleSecureTextInput;
        
        UITextField* passwordTextField = [self textFieldAtIndex:0];
        passwordTextField.placeholder = @"Password...";
    }
    return self;
}

- (BOOL) hasText
{
    UITextField* passwordTextField = [self textFieldAtIndex:0];
    return passwordTextField.hasText;
}

- (NSString*) text
{
    UITextField* passwordTextField = [self textFieldAtIndex:0];
    return passwordTextField.text;
}

- (NSString*) passwordText
{
    UITextField* passwordTextField = [self textFieldAtIndex:0];
    NSString* text = passwordTextField.text;
    if(text && text.length)
    {
        return text;
    }
    else
    {
        return nil;
    }
}

@end
