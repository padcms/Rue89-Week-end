//
//  PCKioskNotificationPopup.m
//  Pad CMS
//
//  Created by tar on 23.08.13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCKioskNotificationPopup.h"
#import "MTLabel.h"

@interface PCKioskNotificationPopup()

@end

@implementation PCKioskNotificationPopup

- (id)initWithSize:(CGSize)size viewToShowIn:(UIView *)view
{
    self = [super initWithSize:size viewToShowIn:view];
    if (self) {
        self.presentationStyle = PCKioskPopupPresentationStyleFromBottom;
    }
    return self;
}

- (void)loadContent {
    [super loadContent];
    self.titleLabel.textAlignment = MTLabelTextAlignmentLeft;
    self.titleLabel.frame = CGRectMake(25, 15, 175, 50);
    //self.titleLabel.text = @"Hello";
    
    self.titleLabel.font = [UIFont fontWithName:self.titleLabel.font.fontName size:25];
    
    self.descriptionLabel.frame = CGRectMake(CGRectGetMaxX(self.titleLabel.frame), 22, 500, 140);
}

- (void)sizeToFitDescriptionLabelText {
    
    CGSize textSize = [self.descriptionLabel.text sizeWithFont:self.descriptionLabel.font constrainedToSize:CGSizeMake(self.descriptionLabel.frame.size.width, 9999) lineBreakMode:NSLineBreakByWordWrapping];
    
    CGFloat newHeight = textSize.height + self.descriptionLabel.frame.origin.y*2 + 10;
    
    CGRect frame = self.frame;
    frame.size.height = newHeight;
    self.frame = frame;
    
    self.blockingView.frame = CGRectMake(self.blockingView.frame.origin.x, self.viewToShowIn.frame.size.height - newHeight, self.blockingView.frame.size.width, newHeight);
    
    self.frame = [self bottomHiddenFrame:YES];
}

- (void)hideAnimationActions {
    self.frame = [self bottomHiddenFrame:YES];
}

@end
