//
//  PCKioskHeaderView.m
//  Pad CMS
//
//  Created by tar on 16.08.13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCKioskHeaderView.h"
#import "RueAccessManager.h"

@interface PCKioskHeaderView()

@property (strong, nonatomic) IBOutlet UIButton *shareButton;
@property (strong, nonatomic) IBOutlet UIButton *contactUsButton;
@property (strong, nonatomic) IBOutlet UIButton *restorePurchasesButton;
@property (strong, nonatomic) IBOutlet UIButton *logoButton;

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView* restorePurchasesActivity;


@end

@implementation PCKioskHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    NSString * fontName = @"QuicksandBold-Regular";
    UIEdgeInsets insets = UIEdgeInsetsMake(4, 0, 0, 0);
    CGFloat fontSize = 16.5;
    
    [self.shareButton.titleLabel setFont:[UIFont fontWithName:fontName size:fontSize]];
    [self.contactUsButton.titleLabel setFont:[UIFont fontWithName:fontName size:fontSize]];
    [self.restorePurchasesButton.titleLabel setFont:[UIFont fontWithName:fontName size:fontSize]];
    
    [self.shareButton setTitleEdgeInsets:insets];
    [self.contactUsButton setTitleEdgeInsets:insets];
    [self.restorePurchasesButton setTitleEdgeInsets:insets];
    
    [self.restorePurchasesButton addObserver:self forKeyPath:@"enabled" options:NSKeyValueObservingOptionNew context:nil];
    
    //subscribe button
    
    //remove placeholer
    CGRect frame = self.subscribeButton.frame;
    [self.subscribeButton removeFromSuperview];
    
    //set the right one
    self.subscribeButton = [[[UINib nibWithNibName:@"PCKioskSubscribeButton" bundle:nil] instantiateWithOwner:nil options:nil] objectAtIndex:0];
    [self addSubview:self.subscribeButton];
    self.subscribeButton.frame = frame;
    [self.subscribeButton.button addTarget:self action:@selector(purchaseAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UITapGestureRecognizer* fiveRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(fiveGestureActivated:)];
    fiveRecognizer.numberOfTouchesRequired = kPublisherAccessNumberOfTouches;
    fiveRecognizer.cancelsTouchesInView = YES;
    [self.logoButton addGestureRecognizer:fiveRecognizer];
    
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if(object == self.restorePurchasesButton && [keyPath isEqualToString:@"enabled"])
    {
        BOOL enabled = [change[@"new"] boolValue];
        if(enabled)
        {
            [self.restorePurchasesActivity stopAnimating];
        }
        else
        {
            [self.restorePurchasesActivity startAnimating];
        }
    }
}

#pragma mark - Button actions

- (IBAction)shareButtonAction:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(shareButtonTapped)]) {
        [self.delegate shareButtonTapped];
    }
}

- (IBAction)contactUsButtonTapped:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(contactUsButtonTapped)]) {
        [self.delegate contactUsButtonTapped];
    }
}

- (IBAction)restorePurchasesButtonTapped:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(restorePurchasesButtonTapped:)]) {
        [self.delegate restorePurchasesButtonTapped:sender];
    }
}
- (void)purchaseAction:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(subscribeButtonTapped:)]) {
        [self.delegate subscribeButtonTapped:self.subscribeButton];
    }
}
- (IBAction)logoButtonTapped:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(logoButtonTapped)]) {
        [self.delegate logoButtonTapped];
    }
}

- (void) fiveGestureActivated:(UIGestureRecognizer*)gesture
{
    if ([self.delegate respondsToSelector:@selector(secretGestureRecognized)])
    {
        [self.delegate secretGestureRecognized];
    }
}

- (void) dealloc
{
    [self.restorePurchasesButton removeObserver:self forKeyPath:@"enabled"];
}

@end
