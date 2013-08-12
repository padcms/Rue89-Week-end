//
//  PCApplicationsListViewController.m
//  Pad CMS
//
//  Created by Maxim Pervushin on 4/19/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCApplicationsListViewController.h"
#import "PCAccountViewController.h"
#import "PCAppDelegate.h"
#import "PCApplication.h"
#import "PCIssuesListViewController.h"
#import "PCRevisionViewController.h"
#import "PCApplicationCell.h"
#import "PCMSMainSplitViewController.h"

@interface PCApplicationsListViewController ()
{
    NSArray *_applications;
}

@end


@implementation PCApplicationsListViewController

@synthesize mainSplitViewController = _mainSplitViewController;
@synthesize issuesListViewController = _issuesViewController;

- (void)dealloc
{
    [_issuesViewController release];
    
    [super dealloc];
}

- (id)init
{
    self = [super init];
    
    if (self != nil)
    {
        _mainSplitViewController = nil;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = NSLocalizedString(@"My Apps", nil);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [PCApplicationCell cellHeight];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_applications != nil)
    {
        return [_applications count];
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ApplicationCell";
    PCApplicationCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[[PCApplicationCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                       reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    PCApplication *currentApplication = [_applications objectAtIndex:indexPath.row];
    
    cell.application = currentApplication;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PCApplication *currentApplication = [_applications objectAtIndex:indexPath.row];

    if (self.issuesListViewController != nil)
    {
        self.issuesListViewController.application = currentApplication;

        if (self.mainSplitViewController != nil)
        {
            [self.mainSplitViewController dismissPopoverViewControllerAnimated:YES];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object 
                        change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"applications"] && [object isKindOfClass:[PCAccount class]])
    {
        if ([[change objectForKey:@"new"] isKindOfClass:[NSNull class]])
        {
            _applications = nil;
            self.issuesListViewController.application = nil;
        }
        else
        {
            _applications = [change objectForKey:@"new"];
        }
        
        [self.tableView reloadData];
    }
}

@end
