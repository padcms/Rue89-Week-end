//
//  RueIssue.h
//  Pad CMS
//
//  Created by Maksym Martyniuk on 11/11/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCIssue.h"
#import "IssuePricingPlan.h"

@interface RueIssue : PCIssue

@property (nonatomic, readonly) BOOL isOld;

@property (nonatomic, readonly) IssuePricingPlan pricingPlan;

@property (nonatomic, retain) NSDate *publishDate;

@property (nonatomic, copy) NSString *titleShort;
@property (nonatomic, copy) NSString * shortIntro;

/**
 @brief Issue tags
 */
@property (nonatomic, retain) NSMutableArray * tags;

@property (nonatomic, retain) NSString * category;

@property (nonatomic, retain) NSString* price;

@property (nonatomic, strong) NSString * author;

@property (nonatomic, retain) NSString * excerpt;

@property (nonatomic, retain) NSString * imageLargeURL;

@property (nonatomic, retain) NSString * imageSmallURL;

@property (nonatomic) NSInteger wordsCount;

@end
