//
//  PCRevisionSummaryPopup.m
//  Pad CMS
//
//  Created by tar on 05.09.13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCRevisionSummaryPopup.h"
#import "PCRevisionSummaryCell.h"

@interface PCRevisionSummaryPopup() <EasyTableViewDelegate>

@end

const float kButtonsHeight = 40.0f;

@implementation PCRevisionSummaryPopup

- (void)loadContent {
    [super loadContent];
    
    CGRect tableViewFrame = CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height);
    
    self.tableView = [[EasyTableView  alloc] initWithFrame:tableViewFrame numberOfColumns:5 ofWidth:250];
    self.tableView.delegate = self;
    self.tableView.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableView.separatorColor = [UIColor clearColor];
    [self.contentView addSubview:self.tableView];
    
    UIImage * homeButtonImage = [UIImage imageNamed:@"summary_home_button"];
    
    UIButton * homeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [homeButton setImage:homeButtonImage forState:UIControlStateNormal];
    homeButton.frame = CGRectMake(560, 146, homeButtonImage.size.width, homeButtonImage.size.height);
    [homeButton addTarget:self action:@selector(homeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.blockingView insertSubview:homeButton atIndex:0];
    
    
    UIImage * menuButtonImage = [UIImage imageNamed:@"summary_menu_button"];
    
    UIButton * menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [menuButton setImage:menuButtonImage forState:UIControlStateNormal];
    menuButton.frame = CGRectMake(622, 146, menuButtonImage.size.width, menuButtonImage.size.height);
    [menuButton addTarget:self action:@selector(menuButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.blockingView insertSubview:menuButton atIndex:0];
}


#pragma mark - Button actions

- (void)homeButtonAction:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(revisionSummaryPopupDidTapHomeButton:)]) {
        [self.delegate revisionSummaryPopupDidTapHomeButton:self];
    }
}

- (void)menuButtonAction:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(revisionSummaryPopupDidTapMenuButton:)]) {
        [self.delegate revisionSummaryPopupDidTapMenuButton:self];
    }
}


#pragma mark - EasyTableViewDelegate

- (UIView *)easyTableView:(EasyTableView *)easyTableView viewForRect:(CGRect)rect {
    
    PCRevisionSummaryCell * cell = [[PCRevisionSummaryCell alloc] initWithFrame:rect];
    //cell.backgroundColor = [[UIColor orangeColor] colorWithAlphaComponent:0.5f];
    
    return cell;
}

- (void)easyTableView:(EasyTableView *)easyTableView setDataForView:(UIView *)view forIndexPath:(NSIndexPath *)indexPath {
    //view.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.3f];
}


#pragma mark - Popup Override stuff

- (void)prepareForPresentation {
    [super prepareForPresentation];
    
    if (self.presentationStyle == PCKioskPopupPresentationStyleFromTop) {
        //self.blockingView.frame = CGRectMake(self.blockingView.frame.origin.x, 0, self.blockingView.frame.size.width, self.frame.size.height + kButtonsHeight);
        
        self.blockingView.frame = [self blockingViewTopHiddenFrame:YES];
        
        self.frame = [self topHiddenFrame:NO];
        self.blockingView.alpha = 1.0f;
        self.blockingView.backgroundColor = [UIColor clearColor];
        self.closeButton.hidden = YES;
    }
}

- (CGRect)topHiddenFrame:(BOOL)hidden{
    
    return CGRectMake(-self.shadowWidth,
                      (hidden ?  -self.frame.size.height + self.shadowWidth -  0 : - self.shadowWidth),
                      self.frame.size.width
                      , self.frame.size.height);
}

- (CGRect)blockingViewTopHiddenFrame:(BOOL)hidden {
    
    return CGRectMake(0,
                      (hidden ?  -self.frame.size.height + self.shadowWidth : 0),
                      self.blockingView.frame.size.width
                      , self.frame.size.height + kButtonsHeight);
}

- (void)showAnimationActions {
    [super showAnimationActions];
    
    if (self.presentationStyle == PCKioskPopupPresentationStyleFromTop) {
        self.blockingView.alpha = 1.0f;
        self.blockingView.frame = [self blockingViewTopHiddenFrame:NO];
    }
}

- (void)hideAnimationActions {
    [super hideAnimationActions];
    
    if (self.presentationStyle == PCKioskPopupPresentationStyleFromTop) {
        self.blockingView.frame = [self blockingViewTopHiddenFrame:YES];
        
    }
}

- (void)hideAnimationCompletionActions {
    
}

@end
