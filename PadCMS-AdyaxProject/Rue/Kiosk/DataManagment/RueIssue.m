//
//  RueIssue.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 11/11/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "RueIssue.h"
#import "PCJSONKeys.h"
#import "NSString+HTML.h"
#import "PCTag.h"

@implementation RueIssue

- (id)initWithParameters:(NSDictionary *)parameters
           rootDirectory:(NSString *)rootDirectory
              backEndURL:(NSURL *)backEndURL
{
    self = [super initWithParameters:parameters rootDirectory:rootDirectory backEndURL:backEndURL];
    if(self)
    {
        self.author = [[parameters objectForKey:PCJSONIssueAuthorKey] copy];
        self.excerpt = [[parameters objectForKey:PCJSONIssueExcerptKey] copy];
        self.imageLargeURL = [[parameters objectForKey:PCJSONIssueImageLargeURLKey] copy];
        self.imageSmallURL = [[parameters objectForKey:PCJSONIssueImageSmallURLKey] copy];
        self.wordsCount = [[parameters objectForKey:PCJSONIssueWordsCountKey] integerValue];
        
        self.category = [[parameters objectForKey:PCJSONIssueCategoryKey] copy];
        
        self.tags = [NSMutableArray new];
        
        NSArray * tagsParameters = [parameters objectForKey:PCJSONIssueTagsKey];
        
        if ([tagsParameters count] > 0) {
            for (NSDictionary * dic in tagsParameters) {
                PCTag * tag = [[PCTag alloc] initWithDictionary:dic];
                [self.tags addObject:tag];
            }
        }
        
        //NSLog(@"TAGS : %@", self.tags);
        
        self.productIdentifier = [[parameters objectForKey:PCJSONIssueProductIDKey] copy];
        self.titleShort = [parameters objectForKey:PCJSONIssueTitleShortKey];
        self.shortIntro = [[parameters objectForKey:PCJSONIssueShortIntroKey] stringByDecodingHTMLEntities];
        self.excerpt = [[[parameters objectForKey:PCJSONIssueExcerptKey] stringByDecodingHTMLEntities] copy];

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
        
        self.publishDate = fullDateFromString([parameters objectForKey:PCJSONIssuePublishDateKey]);
        
        
        
    }
    return self;
}

NSDate* fullDateFromString(NSString* strDate)
{
    if(strDate != nil && [strDate isKindOfClass:[NSString class]] && strDate.length)
    {
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        NSDate* date = [df dateFromString:strDate];
        
        return date;
    }
    else
    {
        return nil;
    }
}

- (NSString *)description
{
    NSString *descriptionString = [NSString stringWithFormat:@"%@\ridentifier: %d\rtitle: %@\r"
                                   "number: %@\rproductIdentifier: %@\rsubscriptionType: %d\r"
                                   "paid: %d\rcolor: %@\rcoverImageThumbnailURL: %@\r"
                                   "coverImageListURL: %@\rcoverImageURL: %@\rupdatedDate: %@\r"
                                   "horisontalMode: %d\rcontentDirectory: %@\r"
                                   "revisions: %@",
                                   [super description],
                                   self.identifier,
                                   self.title,
                                   self.number,
                                   self.productIdentifier,
                                   self.subscriptionType,
                                   self.paid,
                                   [UIColor whiteColor],        //hardcode, warning fix, 16.09.2013
                                   self.coverImageThumbnailURL,
                                   self.coverImageListURL,
                                   self.coverImageURL,
                                   self.updatedDate,
                                   NO,                          //hardcode, warning fix, 16.09.2013
                                   self.contentDirectory,
                                   self.revisions];
    
    return descriptionString;
}

@end
