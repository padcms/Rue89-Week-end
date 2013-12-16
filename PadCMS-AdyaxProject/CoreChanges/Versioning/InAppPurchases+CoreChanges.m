//
//  InAppPurchases+CoreChanges.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 12/13/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "InAppPurchases.h"
#import "PCConfig.h"
#import "PCLocalizationManager.h"

static InAppPurchases *singleton;

@interface InAppPurchases ()
- (NSString *) localizedPrice:(SKProduct*)prod;
@end

@implementation InAppPurchases (CoreChanges)

- (void)repurchase
{
	//_isSubscribed = YES;
	[[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSArray *products = response.products;
	for(SKProduct *product in products)
	{
		if (product)
		{
			[singleton.dataQueue removeObject:product.productIdentifier];
			
			NSLog(@"Product title: %@"       , product.localizedTitle);
			NSLog(@"Product description: %@" , product.localizedDescription);
			NSLog(@"Product price: %@"       , product.price);
			NSLog(@"Product id: %@"          , product.productIdentifier);
			
			NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [self localizedPrice:product], @"localizedPrice",
                                  [NSString stringWithString:product.productIdentifier], @"productIdentifier", nil];
			
			[[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerProductsFetchedNotification object:data];
		}
	}
    
    
    for (NSString *invalidProductId in response.invalidProductIdentifiers)
    {
        NSLog(@"Invalid product id: %@" , invalidProductId);
    }
    
    //[request release];
}

- (void) subscribe
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif
    
    if(self.isSubscribed)
    {
        /*     UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Vous êtes déjà inscrit" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
         [alert show];
         [alert release];*/
        
        return;
    }
    //_isSubscribed=YES;
    //product request
    NSLog(@"subscribing");
	
    
	if([self canMakePurchases])
	{
        //[self purchaseForProductId:@"com.mobile.rue89.oneyear"];
        [self purchaseForProductId:[[PCConfig subscriptions] lastObject]];
	}
	else
	{
        NSString        *title = [PCLocalizationManager localizedStringForKey:@"ALERT_TITLE_CANT_MAKE_PURCHASE"
                                                                        value:@"You can't make the purchase"];
        
        NSString        *buttonTitle = [PCLocalizationManager localizedStringForKey:@"BUTTON_TITLE_OK"
                                                                              value:@"OK"];
        
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:buttonTitle
                                              otherButtonTitles:nil];
		[alert show];
	}
}

- (void)requestProductDataWithProductId:(NSString *)productId
{
	if(![singleton.dataQueue containsObject:productId]  && productId)
	{
		NSLog(@"From requestProductDataWithProductId: %@", productId);
		
		[singleton.dataQueue addObject:productId];
		
		NSSet *productIdentifiers = [NSSet setWithObject:productId];
		//[productId release];
		SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
		productsRequest.delegate = self;
		[productsRequest start];
	}
}

@end
