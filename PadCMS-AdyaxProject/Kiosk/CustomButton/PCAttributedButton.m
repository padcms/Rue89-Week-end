//
//  PCAttributedButton.m
//  Pad CMS
//
//  Created by tar on 21.08.13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCAttributedButton.h"

@implementation PCAttributedButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _titleLabel = [[MTLabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [_titleLabel setBackgroundColor:[UIColor clearColor]];
        [self addSubview:_titleLabel];
    }
    return self;
}

- (void)sizeToFit {
    [super sizeToFit];
    
    [self.titleLabel sizeToFit];
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.titleLabel.frame.size.width, self.titleLabel.frame.size.height);
}

@end
