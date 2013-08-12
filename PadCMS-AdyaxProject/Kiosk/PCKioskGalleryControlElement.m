//
//PCKioskGalleryControlElement.m
//Pad CMS
//
//Created by Oleg Zhitnik on 11.05.12.
//Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCKioskGalleryControlElement.h"
#import "PCKioskShelfSettings.h"
#import "PCConfig.h"

@implementation PCKioskGalleryControlElement

- (void) initCover
{
// no cover
}

#pragma mark - Override

-(void)initLabels
{
	[super initLabels];
	[revisionTitleLabel removeFromSuperview];
}

- (void) initDownloadingProgressComponents
{
	[super initDownloadingProgressComponents];
	KiosqueType kiosqueType = [PCConfig kiosqueType];
	if (kiosqueType == KiosqueTypeAirDccv)
	{
		downloadingProgressView.frame = CGRectMake(self.bounds.size.width/2-deleteButton.frame.size.width/2 -5,readButton.frame.origin.y+readButton.frame.size.height+20, deleteButton.frame.size.width,6);	
		downloadingInfoLabel.frame = CGRectMake(downloadingProgressView.frame.origin.x,downloadingProgressView.frame.origin.y+downloadingProgressView.frame.size.height,downloadingProgressView.frame.size.width,30);
	}
	else if (kiosqueType == KiosqueTypeDefault)
	{
		downloadingProgressView.frame = CGRectMake(self.bounds.size.width/2-deleteButton.frame.size.width/2,readButton.frame.origin.y+readButton.frame.size.height+20, deleteButton.frame.size.width,6);	
		downloadingInfoLabel.frame = CGRectMake(downloadingProgressView.frame.origin.x,downloadingProgressView.frame.origin.y+downloadingProgressView.frame.size.height,downloadingProgressView.frame.size.width,30);
	}
}

-(void)initButtons
{
	[super initButtons];
	
	KiosqueType kiosqueType = [PCConfig kiosqueType];
	
	if (kiosqueType == KiosqueTypeAirDccv)
	{
		UIImageView* line = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"breaking_line"]];
		line.center = CGPointMake(self.bounds.size.width/2, issueTitleLabel.frame.size.height+5);
		[line sizeToFit];
		[self addSubview:line];
		[line release];
	}
	

	issueTitleLabel.frame = CGRectMake(0,0,self.bounds.size.width,40);
	issueTitleLabel.textAlignment = UITextAlignmentCenter;
	
	if (kiosqueType == KiosqueTypeAirDccv)
	{
		downloadButton.frame = CGRectMake(self.bounds.size.width/2-downloadButton.frame.size.width/2,50,downloadButton.frame.size.width,downloadButton.frame.size.height);
		[downloadButton setBackgroundImage:[UIImage imageNamed:@"read"] forState:UIControlStateNormal];
		[downloadButton setTitle:@"" forState:UIControlStateNormal];
		[downloadButton sizeToFit];
		
		cancelButton.frame = CGRectMake(self.bounds.size.width/2-cancelButton.frame.size.width/2,50,cancelButton.frame.size.width,cancelButton.frame.size.height);
		[cancelButton setBackgroundImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
		[cancelButton setTitle:@"" forState:UIControlStateNormal];
		[cancelButton sizeToFit];
		
		readButton.frame = CGRectMake(self.bounds.size.width/2 -20 - readButton.frame.size.width,50,readButton.frame.size.width,readButton.frame.size.height);
		[readButton setBackgroundImage:[UIImage imageNamed:@"read"] forState:UIControlStateNormal];
		[readButton setTitle:@"" forState:UIControlStateNormal];
		[readButton sizeToFit];

		
		deleteButton.frame = CGRectMake(self.bounds.size.width/2 + 20,50, deleteButton.frame.size.width, deleteButton.frame.size.height);
		[deleteButton setBackgroundImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
		[deleteButton setTitle:@"" forState:UIControlStateNormal];
		[deleteButton sizeToFit];

	}
	else if (kiosqueType == KiosqueTypeDefault)
	{
		downloadButton.frame = CGRectMake(self.bounds.size.width/2-downloadButton.frame.size.width/2,50,downloadButton.frame.size.width,downloadButton.frame.size.height);
		cancelButton.frame = CGRectMake(self.bounds.size.width/2-cancelButton.frame.size.width/2,50,cancelButton.frame.size.width,cancelButton.frame.size.height);
		readButton.frame = CGRectMake(self.bounds.size.width/2 - readButton.frame.size.width/2,50,readButton.frame.size.width,readButton.frame.size.height);
		deleteButton.frame = CGRectMake(self.bounds.size.width/2 - deleteButton.frame.size.width/2, 50 + readButton.frame.size.height + 10, deleteButton.frame.size.width, deleteButton.frame.size.height);
		payButton.frame = CGRectMake(self.bounds.size.width/2-downloadButton.frame.size.width/2,50,downloadButton.frame.size.width,downloadButton.frame.size.height);
	
	}
	

}



@end
