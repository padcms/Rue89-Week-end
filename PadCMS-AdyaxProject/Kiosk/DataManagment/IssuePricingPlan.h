//
//  IssuePricingPlan.h
//  Pad CMS
//
//  Created by Maksym Martyniuk on 11/7/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

typedef enum{
    
    IssuePricingPlanFree = 1,
    IssuePricingPlanSubscriptionOnly,
    IssuePricingPlanSubscriptionOrSinglePurchase,
    IssuePricingPlanSinglePurchase
    
}IssuePricingPlan;

NSString* Issue_Pricing_Plan_JSON_Key;

IssuePricingPlan pricingPlanFromString(NSString* string);