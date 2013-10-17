//
//  FacebookPostConfirmView.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 10/16/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "FacebookPostConfirmView.h"
#import <QuartzCore/QuartzCore.h>
#import "NSObject+Block.h"

@interface FacebookPostConfirmView ()
{
    SEL _postAction;
    id _postTarget;
}
@property (nonatomic, weak) IBOutlet UILabel* subtitleLabel;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView* activity;
@property (nonatomic, weak) IBOutlet UIButton* postButton;

@property (nonatomic, weak) IBOutlet UITextView* textView;
@property (nonatomic, weak) IBOutlet UILabel* linkLabel;

@end

@implementation FacebookPostConfirmView

static NSString* post_complete_message;
static NSString* subtitle_default_message;
static NSString* post_button_default_title;

+ (void) initialize
{
#warning Need to localize
    post_complete_message = @"Post is successfuly complete.";
    subtitle_default_message = @"Post this message to your wall.";
    post_button_default_title = @"Post";
}

- (void) awakeFromNib
{
    self.textView.layer.borderWidth = 1.0f;
    self.textView.layer.borderColor = [UIColor colorWithRed:192.0/255.0 green:194.0/255.0 blue:199.0/255.0 alpha:1.0].CGColor;
    self.textView.layer.cornerRadius = 10;
    
    self.subtitleLabel.text = subtitle_default_message;
    
    [self.postButton setTitle:post_button_default_title forState:UIControlStateNormal];
}

- (NSString*)postMessage
{
    return self.textView.text;
}

- (void) setPostMessage:(NSString*)postMessage
{
    self.textView.text = postMessage;
}

- (NSString*) postLink
{
    return self.linkLabel.text;
}

- (void) setPostLink:(NSString *)postLink
{
    self.linkLabel.text = postLink;
}

#pragma clang diagnostic warning push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
- (IBAction)postPresed:(UIButton*)sender
{
    [self.textView resignFirstResponder];
    if(_postTarget && _postAction && [_postTarget respondsToSelector:_postAction])
    {
        [_postTarget performSelector:_postAction];
    }
}
#pragma clang diagnostic warning pop

- (void) setBlockedButton:(BOOL)blocked
{
    if(blocked)
    {
        self.postButton.userInteractionEnabled = NO;
        [self.postButton setSelected:YES];
        [self.activity startAnimating];
    }
    else
    {
        self.postButton.userInteractionEnabled = YES;
        [self.postButton setSelected:NO];
        [self.activity stopAnimating];
    }
}

- (void) setPostAction:(SEL)action target:(id)target
{
    _postAction = action;
    _postTarget = target;
}

- (void) showSuccessWithComplition:(void(^)())complBlock
{
    self.subtitleLabel.text = post_complete_message;
    self.subtitleLabel.textColor = [UIColor colorWithRed:1.0/255.0 green:134.0/255.0 blue:34.0/255.0 alpha:1.0];;
    [self performBlock:complBlock afterDealay:2.0];
}

- (void) showError:(NSError*)error
{
    self.subtitleLabel.text = error.localizedDescription;
    self.subtitleLabel.textColor = [UIColor redColor];
    [self setBlockedButton:NO];
}

@end
