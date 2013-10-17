//
//  FacebookPostConfirmView.h
//  Pad CMS
//
//  Created by Maksym Martyniuk on 10/16/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FacebookPostConfirmView : UIView

@property (nonatomic) NSString* postMessage;
@property (nonatomic) NSString* postLink;

- (void) setPostAction:(SEL)action target:(id)target;

- (void) setBlockedButton:(BOOL)blocked;

- (void) showSuccessWithComplition:(void(^)())complBlock;
- (void) showError:(NSError*)error;

@end
