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

@property (nonatomic, readonly) IssuePricingPlan pricingPlan;

@end
