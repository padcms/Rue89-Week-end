//
//  PCKioskNavigationBar.m
//  Pad CMS
//
//  Created by Oleg Zhitnik on 14.05.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCKioskNavigationBar.h"
#import "PCKioskShelfSettings.h"
#import <QuartzCore/QuartzCore.h>
#import "PCConfig.h"
#import "PCKioskShelfView.h"
#import "PCKioskGalleryView.h"
#import "PCLocalizationManager.h"

@interface PCKioskNavigationBar ()

- (void) assignButtonsHandlers;
- (void) switchKiosViewButtonTapped;

- (void) initButtons;
- (void) initTitle;
- (void) initSearchTextField;

- (void) adjustKioskSwitchViewButton;

@end

@implementation PCKioskNavigationBar
@synthesize delegate = _delegate;
@synthesize searchTextField = _searchTextField;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        self.backgroundColor = UIColorFromRGB(0x252525);
        self.layer.shadowOffset = CGSizeMake(0, 6);
        self.layer.shadowOpacity = 0.3;	
        self.layer.shouldRasterize = YES;
        self.clipsToBounds = YES;
    }
    return self;
}


- (void) initElements
{
    [self initButtons];
    [self assignButtonsHandlers];
    [self adjustKioskSwitchViewButton];
    [self initTitle];
    
    if(![PCConfig isSearchDisabled])
    {
        [self initSearchTextField];
    }
}

#pragma mark - Private

- (void) initButtons
{
    // switch kiosk mode buttons
    NSInteger           btnSize = 32.0f;
	
	switchKioskViewButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[switchKioskViewButton titleLabel].backgroundColor = [UIColor clearColor];
	[self addSubview:switchKioskViewButton];
    switchKioskViewButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    switchKioskViewButton.frame = CGRectMake(self.bounds.size.width - btnSize*3, (self.bounds.size.height-btnSize)/2, btnSize, btnSize);
   	
	if ([PCConfig subscriptions]) {
        subscribeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [subscribeBtn setTitle:[PCLocalizationManager localizedStringForKey:@"KIOSK_NAVIGATION_BAR_BUTTON_TITLE_SUBSCRIBE"
                                                                      value:@"Subscribe"]
                      forState:UIControlStateNormal];
        [subscribeBtn setTitle:@"Abonnement" forState:UIControlStateNormal];

        subscribeBtn.titleLabel.font = [UIFont fontWithName:@"Verdana" size:18];
        subscribeBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
        [subscribeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        subscribeBtn.backgroundColor = [UIColor clearColor];
        [self addSubview:subscribeBtn];
		
		CGRect subscribeFrame = CGRectMake(switchKioskViewButton.frame.origin.x - 150, switchKioskViewButton.frame.origin.y, switchKioskViewButton.frame.size.width*4, switchKioskViewButton.frame.size.height); 
		
		subscribeBtn.frame = subscribeFrame;
		
	}
	
    

}

- (void) initTitle
{
#ifdef NEW_ICONS
    kioskTitleImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"kiosque_title"]];
    [self addSubview:kioskTitleImageView];
    [kioskTitleImageView sizeToFit];
    kioskTitleImageView.center = self.center;
    kioskTitleImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin| UIViewAutoresizingFlexibleRightMargin| UIViewAutoresizingFlexibleBottomMargin;
#else
    kioskTitleLabel = [[UILabel alloc] init];
    kioskTitleLabel.backgroundColor = [UIColor clearColor];
    kioskTitleLabel.font = [UIFont fontWithName:@"Verdana" size:18];
    kioskTitleLabel.textAlignment = UITextAlignmentCenter;
    kioskTitleLabel.textColor = [UIColor whiteColor];
    kioskTitleLabel.text = [PCLocalizationManager localizedStringForKey:@"KIOSK_NAVIGATION_BAR_TITLE"
                                                                  value:@"Kiosk"];
    [self addSubview:kioskTitleLabel];
    [kioskTitleLabel sizeToFit];
    kioskTitleLabel.center = self.center;
    kioskTitleLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin| UIViewAutoresizingFlexibleRightMargin| UIViewAutoresizingFlexibleBottomMargin;
#endif    
}

- (void) initSearchTextField
{
    self.searchTextField = [[UITextField alloc] init];
    self.searchTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.searchTextField.textColor = [UIColor blackColor];
    self.searchTextField.font = [UIFont systemFontOfSize:14.0];
    self.searchTextField.backgroundColor = [UIColor whiteColor];
    self.searchTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.searchTextField.returnKeyType = UIReturnKeySearch;
    self.searchTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.searchTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.searchTextField.clearsOnBeginEditing = YES;
    [self addSubview:self.searchTextField];
    self.searchTextField.frame = CGRectMake(5, 2, 150, self.bounds.size.height-2);
    self.searchTextField.delegate = self;
}

- (void) assignButtonsHandlers
{
    [switchKioskViewButton addTarget:self
                                action:@selector(switchKiosViewButtonTapped)
                      forControlEvents:UIControlEventTouchUpInside];
	if ([PCConfig subscriptions])
	{
		[subscribeBtn addTarget:self
						 action:@selector(showSubscriptionsPopup)
			   forControlEvents:UIControlEventTouchUpInside];
	}
	
}

- (void) adjustKioskSwitchViewButton
{
    NSString        *imageName = nil;
    
    if ([self.delegate currentSubviewTag]==[PCKioskShelfView subviewTag])
    {
        imageName = @"aFlow.png";
    } else if ([self.delegate currentSubviewTag]==[PCKioskGalleryView subviewTag])
            {
                imageName = @"mosaic.png";
            }
    
    if(imageName)
    {
        [switchKioskViewButton setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    }
}

#pragma mark - Button handlers

- (void) switchKiosViewButtonTapped
{
    [self.delegate switchToNextKioskView];
    [self adjustKioskSwitchViewButton];
}

- (void) showSubscriptionsPopup
{
    CGRect popupRect = CGRectMake(subscribeBtn.frame.origin.x-100, subscribeBtn.frame.size.height, subscribeBtn.frame.size.width, 500);
    [self.delegate showSubscriptionsPopupInRect:popupRect];
}


#pragma mark - Search text field delegate methods

- (void)textFieldDidEndEditing:(UITextField *)textField
{
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.searchTextField resignFirstResponder];
    
    NSString        *searchKeyphrase = textField.text;
    
    textField.text = @"";
    
    [self.delegate searchWithKeyphrase:searchKeyphrase];

    return YES;
}

@end
