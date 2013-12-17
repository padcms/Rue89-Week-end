//
//  PCKioskControlElementDetailsView.h
//  Pad CMS
//
//  Created by tar on 20.08.13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTLabel.h"

@class PCRevision;

@interface PCKioskControlElementDetailsView : UIView

@property (nonatomic, readonly) float openedHeight;
//@property (nonatomic, strong) UITextView * descriptionTextView;

- (void)setExcerptString:(NSString *)excerptString;
- (void)setAuthorsString:(NSString *)authorsString;
- (void)setNumberOfWords:(NSInteger)numberOfWords;

- (void) setupForRevision:(PCRevision*)revision;

@end
