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
#import "PCRevision.h"
#import "PCIssue.h"

#import "PCRevision+DataOfDownload.h"

@interface PCRevisionSummaryPopup() <EasyTableViewDelegate>

@property (nonatomic, strong) NSArray * tocItems;
@property (nonatomic, strong) NSArray* revisionsList;

@end

const float kButtonsHeight = 60.0f;

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
    
    self.backgroundColor = [UIColor clearColor];

}

- (void)loadContent2 {
    
    [self loadTableView];
    
    CGRect frame = self.frame;
    frame.size.height += kButtonsHeight;
    self.frame = frame;
    
    CGFloat insetSize = 30;
    CGFloat rightInset = 5;
    
    UIEdgeInsets homeInsets = UIEdgeInsetsMake(0, insetSize, insetSize, rightInset);
    UIEdgeInsets menuInsets = UIEdgeInsetsMake(0, rightInset, insetSize, insetSize);
    
    UIImage * homeButtonImage = [UIImage imageNamed:@"summary_home_button"];
    
    
    UIButton * homeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [homeButton setImage:homeButtonImage forState:UIControlStateNormal];
    [homeButton setContentEdgeInsets:homeInsets];
    homeButton.frame = CGRectMake(560 - insetSize, 146, homeButtonImage.size.width + insetSize + rightInset, homeButtonImage.size.height + insetSize);
    [homeButton addTarget:self action:@selector(homeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self insertSubview:homeButton atIndex:0];
    
    
    UIImage * menuButtonImage = [UIImage imageNamed:@"summary_menu_button"];
    
    UIButton * menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [menuButton setImage:menuButtonImage forState:UIControlStateNormal];
    [menuButton setContentEdgeInsets:menuInsets];
    menuButton.frame = CGRectMake(622 - rightInset, 146, menuButtonImage.size.width + insetSize + rightInset, menuButtonImage.size.height + insetSize);
    [menuButton addTarget:self action:@selector(menuButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self insertSubview:menuButton atIndex:0];
    

}

- (void) setRevisionsList:(NSArray*)revisions
{
    _revisionsList = revisions;
    [self.tableView.tableView reloadData];
}

- (void) loadTableView
{
    if(self.tableView)
    {
        [self.tableView removeFromSuperview];
    }
    
    CGRect tableViewFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    
    self.tableView = [[EasyTableView  alloc] initWithFrame:tableViewFrame numberOfColumns:0 ofWidth:250];
    self.tableView.delegate = self;
    self.tableView.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableView.separatorColor = [UIColor clearColor];
    [self addSubview:self.tableView];
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

- (NSUInteger)numberOfCellsForEasyTableView:(EasyTableView *)view inSection:(NSInteger)section
{
    return self.revisionsList.count + 1;
}

- (UIView *)easyTableView:(EasyTableView *)easyTableView viewForRect:(CGRect)rect
{
    PCRevisionSummaryCell * cell = [[PCRevisionSummaryCell alloc] initWithFrame:rect];
    //cell.backgroundColor = [[UIColor orangeColor] colorWithAlphaComponent:0.5f];
    
    return cell;
}

- (void)easyTableView:(EasyTableView *)easyTableView setDataForView:(UIView *)view forIndexPath:(NSIndexPath *)indexPath
{
    PCRevisionSummaryCell * cell = (PCRevisionSummaryCell *)view;
    
    if(indexPath.row >= self.revisionsList.count)
    {
        //help view cell
        [cell setTitle:nil];
    }
    else
    {
        //PCTocItem * tocItem = self.tocItems[indexPath.row];
        PCRevision* revision = [self.revisionsList objectAtIndex:indexPath.row];
        
        if(revision.issue.titleShort && [revision.issue.titleShort isKindOfClass:[NSString class]] && revision.issue.titleShort.length)
        {
            [cell setTitle:revision.issue.titleShort];
        }
        else
        {
            [cell setTitle:revision.issue.title];
        }
        
        if(revision.issue.shortIntro && [revision.issue.shortIntro isKindOfClass:[NSString class]] && revision.issue.shortIntro.length)
        {
            [cell setDescription:revision.issue.shortIntro];
        }
        else
        {
            [cell setDescription:revision.issue.excerpt];
        }
    }
}

- (void)easyTableView:(EasyTableView *)easyTableView selectedView:(UIView *)selectedView atIndexPath:(NSIndexPath *)indexPath deselectedView:(UIView *)deselectedView {
    
    /*if ([self.delegate respondsToSelector:@selector(revisionSummaryPopup:didSelectIndex:)]) {
        [self.delegate revisionSummaryPopup:self didSelectIndex:indexPath.row];
    }*/
    if(indexPath.row >= self.revisionsList.count)
    {
        //help view cell presed
    }
    else if([self.delegate respondsToSelector:@selector(revisionSummaryPopup:didSelectRevision:)])
    {
        [self.delegate revisionSummaryPopup:self didSelectRevision:[self.revisionsList objectAtIndex:indexPath.row]];
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
    
    return CGRectMake(0,
                      (hidden ?  -self.frame.size.height + kButtonsHeight : 0),
                      self.frame.size.width
                      , self.frame.size.height);
}

- (CGRect)blockingViewTopHiddenFrame:(BOOL)hidden {
    
    return CGRectMake(0,
                      (hidden ?  -self.frame.size.height : 0),
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
