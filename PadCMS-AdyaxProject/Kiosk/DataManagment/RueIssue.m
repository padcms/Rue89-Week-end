//
//  RueIssue.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 11/11/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "RueIssue.h"

@implementation RueIssue

- (id)initWithParameters:(NSDictionary *)parameters
           rootDirectory:(NSString *)rootDirectory
              backEndURL:(NSURL *)backEndURL
{
    self = [super initWithParameters:parameters rootDirectory:rootDirectory backEndURL:backEndURL];
    if(self)
    {
        //------------------------ Pricing Plan -------------------------------------------------------
        NSString* pricinsPlanStr = parameters[Issue_Pricing_Plan_JSON_Key];
        if(pricinsPlanStr && [pricinsPlanStr isKindOfClass:[NSString class]] && pricinsPlanStr.length)
        {
            _pricingPlan = pricingPlanFromString(pricinsPlanStr);
        }
        if(_pricingPlan == 0)
        {
            if(self.price)
            {
                _pricingPlan = IssuePricingPlanSinglePurchase;
            }
            else
            {
                _pricingPlan = IssuePricingPlanFree;
            }
        }
        //---------------------------------------------------------------------------------------------
    }
    return self;
}

@end
