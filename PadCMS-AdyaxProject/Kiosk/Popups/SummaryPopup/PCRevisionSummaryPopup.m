//
//  PCRevisionSummaryPopup.m
//  Pad CMS
//
//  Created by tar on 05.09.13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCRevisionSummaryPopup.h"
#import "PCRevisionSummaryCell.h"
#import "PCTocItem.h"

@interface PCRevisionSummaryPopup() <EasyTableViewDelegate>

@property (nonatomic, strong) NSArray * tocItems;

@end

const float kButtonsHeight = 40.0f;

@implementation PCRevisionSummaryPopup

- (id)initWithSize:(CGSize)size viewToShowIn:(UIView *)view tocItems:(NSArray *)aTocItems {
    self = [super initWithSize:size viewToShowIn:view];
    
    if (self) {
        self.tocItems = aTocItems;
        
        [self loadContent2];
    }
    
    return self;
}

- (void)loadContent {
    [super loadContent];
    

}

- (void)loadContent2 {
    
    CGRect tableViewFrame = CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height);
    
    self.tableView = [[EasyTableView  alloc] initWithFrame:tableViewFrame numberOfColumns:self.tocItems.count ofWidth:250];
    self.tableView.delegate = self;
    self.tableView.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableView.separatorColor = [UIColor clearColor];
    [self.contentView addSubview:self.tableView];
    
    CGRect frame = self.frame;
    frame.size.height += kButtonsHeight;
    self.frame = frame;
    
    UIImage * homeButtonImage = [UIImage imageNamed:@"summary_home_button"];
    
    UIButton * homeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [homeButton setImage:homeButtonImage forState:UIControlStateNormal];
    homeButton.frame = CGRectMake(560, 146, homeButtonImage.size.width, homeButtonImage.size.height);
    [homeButton addTarget:self action:@selector(homeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self insertSubview:homeButton atIndex:0];
    
    
    UIImage * menuButtonImage = [UIImage imageNamed:@"summary_menu_button"];
    
    UIButton * menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [menuButton setImage:menuButtonImage forState:UIControlStateNormal];
    menuButton.frame = CGRectMake(622, 146, menuButtonImage.size.width, menuButtonImage.size.height);
    [menuButton addTarget:self action:@selector(menuButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self insertSubview:menuButton atIndex:0];
    

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
    
    PCRevisionSummaryCell * cell = (PCRevisionSummaryCell *)view;
    
    PCTocItem * tocItem = self.tocItems[indexPath.row];
    
    
    cell.titleLabel.text = tocItem.title;
    cell.descriptionLabel.text = tocItem.tocItemDescription;
    
    [cell layoutSubviews];
    [cell setNeedsDisplay];
}

- (void)easyTableView:(EasyTableView *)easyTableView selectedView:(UIView *)selectedView atIndexPath:(NSIndexPath *)indexPath deselectedView:(UIView *)deselectedView {
    
    if ([self.delegate respondsToSelector:@selector(revisionSummaryPopup:didSelectIndex:)]) {
        [self.delegate revisionSummaryPopup:self didSelectIndex:indexPath.row];
    }
}

#pragma mark - Popup Override stuff

- (void)prepareForPresentation {
    [super prepareForPresentation];
    
    if (self.presentationStyle == PCKioskPopupPresentationStyleFromTop) {
        //self.blockingView.frame = CGRectMake(self.blockingView.frame.origin.x, 0, self.blockingView.frame.size.width, self.frame.size.height + kButtonsHeight);
        
        //self.blockingView.frame = [self blockingViewTopHiddenFrame:YES];
        
        [self removeFromSuperview];
        
        [self.blockingView.superview addSubview:self];
        
        self.frame = [self topHiddenFrame:YES];
        self.blockingView.alpha = 0.0f;
        self.blockingView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
        self.closeButton.hidden = YES;
    }
}

- (CGRect)topHiddenFrame:(BOOL)hidden{
    
    return CGRectMake(-self.shadowWidth,
                      (hidden ?  -self.frame.size.height + self.shadowWidth + kButtonsHeight : - self.shadowWidth),
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
        self.frame = [self topHiddenFrame:NO];
    }
}

- (void)hideAnimationActions {
    [super hideAnimationActions];
    
    if (self.presentationStyle == PCKioskPopupPresentationStyleFromTop) {
        self.frame = [self topHiddenFrame:YES];
        self.blockingView.alpha = 0.0f;
    }
}

- (void)hideAnimationCompletionActions {
    
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView * subview = [super hitTest:point withEvent:event];
    
    
    if (subview == self) {
        return nil;
    }
    
    return subview;
}

@end
