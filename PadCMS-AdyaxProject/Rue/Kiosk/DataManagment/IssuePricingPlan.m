//
//  IssuePricingPlan.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 11/7/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//


#import "IssuePricingPlan.h"

NSString* Issue_Pricing_Plan_JSON_Key = @"issue_pricing_plan";

NSString* freePricingPlanString = @"free";
NSString* subscriptionOnlyPricingPlanString = @"subscription_only";
NSString* subscriptionOrSinglePurchasePricingPlanString = @"subscription_or_single_issue_purchase";
NSString* singlePurchasePricingPlanString = @"single_issue_purchase_only";


IssuePricingPlan pricingPlanFromString(NSString* string)
{
    if([string isEqualToString:freePricingPlanString])
        return IssuePricingPlanFree;
    
    if([string isEqualToString:subscriptionOnlyPricingPlanString])
        return IssuePricingPlanSubscriptionOnly;
    
    if([string isEqualToString:subscriptionOrSinglePurchasePricingPlanString])
        return IssuePricingPlanSubscriptionOrSinglePurchase;
    
    if([string isEqualToString:singlePurchasePricingPlanString])
        return IssuePricingPlanSinglePurchase;
    
    return 0;
}