//
//  PCKioskControlElementDetailsView.h
//  Pad CMS
//
//  Created by tar on 20.08.13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTLabel.h"

@interface PCKioskControlElementDetailsView : UIView

//@property (nonatomic, strong) UITextView * descriptionTextView;
@property (nonatomic, strong) RTLabel * excerptLabel;
@property (nonatomic, strong) UILabel * autorsLabel;
@property (nonatomic, strong) UILabel * numberOfWordsLabel;

- (void)setExcerptString:(NSString *)excerptString;
- (void)setAuthorsString:(NSString *)authorsString;
- (void)setNumberOfWords:(NSInteger)numberOfWords;

@end
