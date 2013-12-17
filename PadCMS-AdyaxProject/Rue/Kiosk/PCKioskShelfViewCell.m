//
//  PCKioskShelfViewCell.m
//  Pad CMS
//
//  Created by tar on 18.09.13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCKioskShelfViewCell.h"
#import "PCKioskAdvancedControlElement.h"
#import "PCKioskShelfSettings.h"

@implementation PCKioskShelfViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        CGRect frame = CGRectMake(KIOSK_ADVANCED_SHELF_COLUMN_MARGIN_LEFT, 0, screenSize.width - KIOSK_ADVANCED_SHELF_COLUMN_MARGIN_LEFT * 2, KIOSK_ADVANCED_SHELF_ROW_HEIGHT);
        _controlElement = [[PCKioskAdvancedControlElement alloc] initWithFrame:frame];
        [self addSubview:_controlElement];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
