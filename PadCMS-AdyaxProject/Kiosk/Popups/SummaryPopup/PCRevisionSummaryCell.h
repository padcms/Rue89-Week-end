//
//  PCRevisionSummaryCell.h
//  Pad CMS
//
//  Created by tar on 05.09.13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTLabel.h"
#import "RTLabelWithWordWrap.h"

@interface PCRevisionSummaryCell : UIView <MTLabelDelegate>

@property (nonatomic, strong) MTLabel * titleLabel;
@property (nonatomic, strong) RTLabelWithWordWrap * descriptionLabel;

- (void)setNeedsDisplayHacked;

- (void) setTitle:(NSString*)title;
- (void) setDescription:(NSString*)description;

@end
