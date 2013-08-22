//
//  PCKioskControlElementDetailsView.h
//  Pad CMS
//
//  Created by tar on 20.08.13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOTextView.h"

@interface PCKioskControlElementDetailsView : UIView

@property (nonatomic, strong) UITextView * descriptionTextView;
@property (nonatomic, strong) UILabel * autorsLabel;
@property (nonatomic, strong) UILabel * numberOfWordsLabel;

@end
