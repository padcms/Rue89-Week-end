//
//  PCAccountViewController.m
//  Pad CMS
//
//  Created by Maxim Pervushin on 4/19/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCAccountViewController.h"
#import "PCAppDelegate.h"
#import "PCAccount.h"
#import "PCUserInfo.h"
#import "DisconnectButtonCell.h"

#define AccountIconImage @"top-bar-button-account-image.png"

@interface PCAccountViewController ()

@property (retain, nonatomic) IBOutlet UITableView *tableView;

@end


@implementation PCAccountViewController
@synthesize tableView = _tableView;

@synthesize containerPopoverController = _containerPopoverController;

- (void)dealloc
{
    [_containerPopoverController release];
    [_tableView release];
    [super dealloc];
}

- (id)init
{
    self = [super initWithNibName:@"PCAccountViewController" bundle:[NSBundle mainBundle]];

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = NSLocalizedString(@"Account", nil);
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)disconnectButtonTapped:(UIButton *)sender
{
    PCAppDelegate *appDelegate = (PCAppDelegate *)[UIApplication sharedApplication].delegate;
    PCAccount *account = appDelegate.account;
    [account logOut];
    
    [self.containerPopoverController dismissPopoverAnimated:YES];
}

#pragma mark UITableViewDataSource, UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            return 3;
            break;
        case 1:
            return 1;
            break;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *textCellId = @"TextCell";
    static NSString *disconnectButtonCellId = @"DisconnectButtonCell";
    
    UITableViewCell *cell = nil;
    
    switch (indexPath.section)
    {
        case 0:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:textCellId];
        
            if (cell == nil)
            {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:textCellId] 
                        autorelease];
            }
            
            switch (indexPath.row)
            {
                case 0:
                    cell.textLabel.text = NSLocalizedString(@"Connected with:", nil);
                    cell.textLabel.textColor = [UIColor blackColor];
                    cell.imageView.image = [UIImage imageNamed:AccountIconImage];
                    break;
                case 1:
                {
                    PCAppDelegate *appDelegate = (PCAppDelegate *)[UIApplication sharedApplication].delegate;
                    PCAccount *account = appDelegate.account;
                    cell.textLabel.text = account.userInfo.firstName;
                    cell.textLabel.textColor = [UIColor orangeColor];
                    cell.imageView.image = [UIImage imageNamed:AccountIconImage];
                    cell.imageView.hidden = YES;
                }
                    break;
                case 2:
                {
                    PCAppDelegate *appDelegate = (PCAppDelegate *)[UIApplication sharedApplication].delegate;
                    PCAccount *account = appDelegate.account;
                    cell.textLabel.text = account.userInfo.lastName;
                    cell.textLabel.textColor = [UIColor orangeColor];
                    cell.imageView.image = [UIImage imageNamed:AccountIconImage];
                    cell.imageView.hidden = YES;
                }
                    break;
            }
        }
            break;
            
        case 1:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:disconnectButtonCellId];

            if (cell == nil)
            {
                cell = [[[DisconnectButtonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:disconnectButtonCellId] 
                        autorelease];
                DisconnectButtonCell* disconnectButtonCell = (DisconnectButtonCell *)cell;
                [disconnectButtonCell.disconnectButton addTarget:self action:@selector(disconnectButtonTapped:) 
                                                forControlEvents:UIControlEventTouchUpInside];
            }
        }
            break;
    }

    return cell;
}

@end
