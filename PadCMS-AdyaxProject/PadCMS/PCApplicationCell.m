//
//  PCApplicationCell.m
//  Pad CMS
//
//  Created by Maxim Pervushin on 5/17/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCApplicationCell.h"
#import "PCApplication.h"

#define ApplicationCellHeight 80
#define ApplicationCellBorder 10

@interface PCApplicationCell ()
{
    UIImageView *_emblemImageView;
    UILabel *_titleLabel;
    UILabel *_clientLabel;
}

@end


@implementation PCApplicationCell

@synthesize application = _application;

- (void)dealloc
{
    [_emblemImageView release];
    [_titleLabel release];
    [_clientLabel release];
    
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        _emblemImageView = [[UIImageView alloc] init];
//        _emblemImageView.backgroundColor = [UIColor redColor];
        [self addSubview:_emblemImageView];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont boldSystemFontOfSize:_titleLabel.font.pointSize];
//        _titleLabel.backgroundColor = [UIColor blueColor];
        [self addSubview:_titleLabel];
        
        _clientLabel = [[UILabel alloc] init];
        _clientLabel.font = [UIFont systemFontOfSize:_clientLabel.font.pointSize - 2];
//        _clientLabel.backgroundColor = [UIColor greenColor];
        [self addSubview:_clientLabel];
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGRect frame = self.frame;
    
    _emblemImageView.frame = CGRectMake(ApplicationCellBorder, 
                                        ApplicationCellBorder, 
                                        ApplicationCellHeight - (ApplicationCellBorder * 2), 
                                        ApplicationCellHeight - (ApplicationCellBorder * 2));
    
    _titleLabel.frame = CGRectMake(ApplicationCellHeight, 
                                   ApplicationCellBorder, 
                                   frame.size.width - ApplicationCellHeight, 
                                   (frame.size.height - (ApplicationCellBorder * 3)) / 2);
    
    _clientLabel.frame = CGRectMake(ApplicationCellHeight, 
                                    ((frame.size.height - (ApplicationCellBorder * 3)) / 2) + ApplicationCellBorder * 2, 
                                    frame.size.width - ApplicationCellHeight, 
                                    (frame.size.height - (ApplicationCellBorder * 3)) / 2);
}

- (void)setApplication:(PCApplication *)application
{
    if (_application != application)
    {
        [_application release];
        _application = [application retain];
    }
 
#warning Maxim Pervushin. TODO: load proper application emblem    
    _emblemImageView.image = [UIImage imageNamed:@"application-cover-placeholder.jpg"];
    _titleLabel.text = _application.title;
#warning Maxim Pervushin. TODO: what is client?    
    _clientLabel.text = @"Foo Bar Baz";
}

+ (CGFloat)cellHeight
{
    return ApplicationCellHeight;
}

@end
