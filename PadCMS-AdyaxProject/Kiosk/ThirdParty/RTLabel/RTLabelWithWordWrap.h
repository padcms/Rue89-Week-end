//
//  RTLabelWithWordWrap.h
//  Pad CMS
//
//  Created by Maksym Martyniuk on 10/8/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "RTLabel.h"

#define RTTextLineBreakModeTruncatingTail kCTLineBreakByTruncatingTail

@interface RTLabelWithWordWrap : RTLabel

@property (nonatomic, assign) int linesNumber;
@property (nonatomic, assign) BOOL shouldResizeHeightToFit;

@end
