//
//  PCSQLLiteModelBuilder+CoreChanges.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 12/13/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCSQLLiteModelBuilder.h"
#import "FMDatabase.h"
#import "PCLocalizationManager.h"

@interface PCSQLLiteModelBuilder ()
+ (PCPageElement*)buildPageElement:(FMResultSet*)elementData withDataBase:(FMDatabase*)dataBase;
@end

@implementation PCSQLLiteModelBuilder (CoreChanges)

+ (void) addPagesFromSQLiteBaseWithPath:(NSString*)path toRevision:(PCRevision*)revision
{
    FMDatabase* base = [[FMDatabase alloc] initWithPath:path];
    [base open];
    [base setShouldCacheStatements:YES];
    NSString* pagesQuery = [NSString stringWithFormat:@"select * from %@",PCSQLitePageTableName];
	NSMutableArray* wrongPages = [NSMutableArray array];
    FMResultSet* pages = [base executeQuery:pagesQuery];
    
    while ([pages next])
    {
        PCPage* page = [[PCPage alloc] init];
        page.identifier = [pages intForColumn:PCSQLiteIDColumnName];
        page.machineName = [pages stringForColumn:PCSQLiteMachineNameColumnName];
        NSInteger templateID = [pages intForColumn:PCSQLiteTemplateColumnName];
        page.pageTemplate = [[PCPageTemplatesPool templatesPool] templateForId:templateID];
        
        
        
        page.title = [pages stringForColumn:PCSQLiteTitleColumnName];
        page.horisontalPageIdentifier = [pages intForColumn:PCSQLiteHorisontalPageIDColumnName];
        
        NSString* pageImpositionQuery = [NSString stringWithFormat:@"select * from %@ where %@=?",PCSQLitePageImpositionTableName,PCSQLitePageIDColumnName];
        FMResultSet* pageImposition = [base executeQuery:pageImpositionQuery,[NSNumber numberWithInt:page.identifier]];
        
        while ([pageImposition next])
        {
            NSInteger pageID = [pageImposition intForColumn:PCSQLiteIsLinkedToColumnName];
            NSString* positionType = [pageImposition stringForColumn:PCSQLitePositionTypeColumnName];
            PCPageTemplateConnectorOptions option = -1;
            
            if ([positionType isEqualToString:PCSQLitePositionRightTypeValue])
                option = PCTemplateRightConnector;
            
            if ([positionType isEqualToString:PCSQLitePositionLeftTypeValue])
                option = PCTemplateLeftConnector;
            
            if ([positionType isEqualToString:PCSQLitePositionTopTypeValue])
                option = PCTemplateTopConnector;
            
            if ([positionType isEqualToString:PCSQLitePositionBottomTypeValue])
                option = PCTemplateBottomConnector;
            
			[page.links setObject:[NSNumber numberWithInt:pageID] forKey:[NSNumber numberWithInt:option]];
        }
		
		if (page.pageTemplate == nil)
		{
            
			[wrongPages addObject:page];
			continue;
		}
        
        NSString* elementsQuery = [NSString stringWithFormat:@"select * from %@ where %@=?",PCSQLiteElementTableName,PCSQLitePageIDColumnName];
        FMResultSet* elements = [base executeQuery:elementsQuery,[NSNumber numberWithInt:page.identifier]];
        while ([elements next])
        {
            PCPageElement* element = [self buildPageElement:elements withDataBase:base];
            if (element != nil){
                [page.elements addObject:element];
                element.page = page;
                
            }
        }
        [revision.pages addObject:page];
        
        //        [page setMagazine:magazine];
        page.revision = revision;
        
    }
	
	for (PCPage* page in wrongPages) {
		[revision.pages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			PCPage* p = (PCPage*)obj;
			NSArray* keys = [p.links allKeysForObject:[NSNumber numberWithInt:page.identifier]];
			for (NSNumber* key in keys) {
				NSNumber* newPageIdToLink = [page.links objectForKey:key];
				if (newPageIdToLink)
				{
					[p.links setObject:newPageIdToLink forKey:key];
				}
				else {
					[p.links removeObjectForKey:key];
				}
			}
		}];
        
	}
    
    NSString* horisontalPagesQuery = [NSString stringWithFormat:@"select * from %@",PCSQLitePageHorisontalTableName];
    FMResultSet* horisontalPages = [base executeQuery:horisontalPagesQuery];
    
    [revision.horizontalToc removeAllObjects];
    
    while ([horisontalPages next])
    {
        NSInteger horisontalPageId = [horisontalPages intForColumn:PCSQLiteIDColumnName];
        NSString* resources = [horisontalPages stringForColumn:PCSQLiteResourceColumnName];
        [revision.horizontalPages setObject:resources forKey:[NSNumber numberWithInt:horisontalPageId]];
        PCHorizontalPage* horizontalPage = [[PCHorizontalPage alloc] init];
        horizontalPage.identifier = [NSNumber numberWithInt:horisontalPageId];
        [revision.horisontalPagesObjects setObject:horizontalPage forKey:[NSNumber numberWithInt:horisontalPageId]];
        NSString *horisontalTocItemPath = [resources stringByReplacingOccurrencesOfString:@"1024-768" withString:@"204-153"];
        [revision.horisontalTocItems setObject:horisontalTocItemPath forKey:[NSNumber numberWithInt:horisontalPageId]];
        
        PCTocItem *tocItem = [[PCTocItem alloc] init];
        tocItem.firstPageIdentifier = horizontalPage.identifier.integerValue;
        tocItem.thumbStripe = [@"horisontal_toc_items" stringByAppendingPathComponent:horisontalTocItemPath];
        [revision.horizontalToc addObject:tocItem];
    }
    
    NSString* menusQuery = [NSString stringWithFormat:@"select * from %@",PCSQLiteMenuTableName];
    FMResultSet* menus = [base executeQuery:menusQuery];
    
    [revision.toc removeAllObjects];
    
    while ([menus next])
    {
        NSString *title = [menus stringForColumn:PCSQLiteTitleColumnName];
        NSString *description = [menus stringForColumn:PCSQLiteDescriptionColumnName];
        NSString *colorString = [menus stringForColumn:PCSQLiteColorColumnName];
        NSString *thumbStripe = [menus stringForColumn:PCSQLiteThumbStripeColumnName];
        NSString *thumbSummary = [menus stringForColumn:PCSQLiteThumbSummaryColumnName];
        NSString *firstPageIdentifierString = [menus stringForColumn:PCSQLiteFirstpageIDColumnName];
        
        //        if (thumbStripe == nil ||
        //            [thumbStripe isEqualToString:@""] ||
        //            firstPageIdentifierString == nil ||
        //            [firstPageIdentifierString isEqualToString:@""]) {
        //            continue;
        //        }
        
        PCTocItem *tocItem = [[PCTocItem alloc] init];
        tocItem.title = title;
        tocItem.tocItemDescription = description;
        
        if (colorString != nil && ![colorString isEqualToString:@""]) {
            tocItem.color = [PCDataHelper colorFromString:colorString];
        }
        
        tocItem.thumbStripe = thumbStripe;
        tocItem.thumbSummary = thumbSummary;
        tocItem.firstPageIdentifier = firstPageIdentifierString.integerValue;
        
        PCPage* page = [revision pageWithId:tocItem.firstPageIdentifier];
        if (page != nil && tocItem.color != nil) {
            page.color = tocItem.color;
        }
        
        [revision.toc addObject:tocItem];
    }
    
    [revision updateColumns];
	
	if ([wrongPages lastObject])
	{
        /*	NSMutableString* message = [NSMutableString stringWithString:@"Undefined template on pages with id: "];
         for (PCPage* p in wrongPages) {
         [message appendString:[NSString stringWithFormat:@"%d ",p.identifier]];
         }*/
        //	[message appendString:[NSString stringWithFormat:@"in %@", revision.issue.title]];
		NSString* message = [PCLocalizationManager localizedStringForKey:@"MSG_PAGE_WITH_NOT_IMPLEMENTED_TEMPLATE_IN_REVISION"
                                                                   value:@"Your application can't display all the pages of this magazine because it has not been updated. Please update it"];
        
		dispatch_async(dispatch_get_main_queue(), ^{
			UIAlertView* alert = [[UIAlertView alloc] initWithTitle:[PCLocalizationManager localizedStringForKey:@"TITLE_WARNING"
                                                                                                           value:@"Warning!"]
                                                            message:message
                                                           delegate:nil
                                                  cancelButtonTitle:[PCLocalizationManager localizedStringForKey:@"BUTTON_TITLE_OK"
                                                                                                           value:@"OK"]
                                                  otherButtonTitles:nil];
			[alert show];
		});
		
	}
}

@end
