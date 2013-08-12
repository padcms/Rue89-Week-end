//
//  DisconnectButtonCell.m
//  Pad CMS
//
//  Created by Maxim Pervushin on 5/14/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "DisconnectButtonCell.h"

#define DisconnectButtonBackgroundImage @"button-red.png"
#define DisconnectButtonWidth 81
#define DisconnectButtonHeight 29


@interface DisconnectButtonCell ()

- (void)configure;

@end


@implementation DisconnectButtonCell

@synthesize disconnectButton = _disconnectButton;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        [self configure];
    }
    
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        [self configure];
    }
    
    return self;
}

- (void)configure
{
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    self.backgroundView = backgroundView;
    [backgroundView release];

    self.backgroundColor = [UIColor clearColor];
    
    _disconnectButton = [[UIButton alloc] init];
    [_disconnectButton setBackgroundImage:[UIImage imageNamed:DisconnectButtonBackgroundImage] 
                                 forState:UIControlStateNormal];
    [_disconnectButton setTitle:NSLocalizedString(@"Disconnect", nil) 
                       forState:UIControlStateNormal];

    _disconnectButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    
    [self.contentView addSubview:_disconnectButton];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = self.contentView.frame;
    
    CGFloat disconnectButtonLeft = frame.size.width - 10 - DisconnectButtonWidth;
    CGFloat disconnectButtonTop = (frame.size.height - DisconnectButtonHeight) / 2;
    
    _disconnectButton.frame = CGRectMake(disconnectButtonLeft, disconnectButtonTop, DisconnectButtonWidth, DisconnectButtonHeight);
}

@end
