//
//  CostomTouchesView.h
//  Pad CMS
//
//  Created by Maksym Martyniuk on 2/4/14.
//  Copyright (c) 2014 Adyax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CostomTouchesViewDelegate.h"

@interface CostomTouchesView : UIView

@property (nonatomic, weak) id<CostomTouchesViewDelegate> delegate;

@end
