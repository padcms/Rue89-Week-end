//
//  RueDiaporamaInLongArticleViewController.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 11/25/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "RueDiaporamaInLongArticleViewController.h"
#import "PCScrollView.h"

@interface RueDiaporamaInLongArticleViewController ()

@property (nonatomic, strong) PCScrollView* slidersView;
@property (nonatomic, strong) NSArray* slideViewControllers;
@property (nonatomic, assign) CGRect sliderRect;

@end

@implementation RueDiaporamaInLongArticleViewController

- (void)loadView
{
    [super loadView];
    self.slidersView = [[PCScrollView alloc] initWithFrame:self.view.frame];
    //self.slidersView.delegate = self;
    self.slidersView.contentSize = CGSizeZero;
    self.slidersView.bounces = NO;
    self.slidersView.showsVerticalScrollIndicator = NO;
    self.slidersView.showsHorizontalScrollIndicator = NO;
    self.slidersView.clipsToBounds = YES;
    self.slidersView.alwaysBounceVertical = NO;
    self.slidersView.alwaysBounceHorizontal = NO;
    self.slidersView.pagingEnabled = YES;
    self.slidersView.delaysContentTouches = NO;
    self.slidersView.autoresizesSubviews = NO;
    self.slidersView.autoresizingMask = UIViewAutoresizingNone;
    
    self.slidersView.scrollEnabled = NO;
    
    self.mainScrollView.scrollEnabled = NO;
    [self.mainScrollView addSubview:self.slidersView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSArray* slideElements = [page elementsForType:PCPageElementTypeSlide];
    
    self.sliderRect = [self activeZoneRectForType:PCPDFActiveZoneScroller];
    
    NSMutableArray* slideControllers = [[NSMutableArray alloc]initWithCapacity:slideElements.count];
    
    if (slideElements && [slideElements count] > 0)
    {
        for (unsigned i = 0; i < [slideElements count]; i++)
        {
            PCPageElementSlide* element = [slideElements objectAtIndex:i];
            float scale = self.slidersView.frame.size.width / element.size.width;
            CGSize elementSize = element.size;
            if (element.size.width*element.size.height) {
                elementSize.height *= scale;
                elementSize.width *= scale;
            } else {
                elementSize.height = self.slidersView.frame.size.height;
                elementSize.width = self.slidersView.frame.size.width;
            }
            
            
            CGRect newSlideRect = CGRectMake(self.slidersView.frame.size.width*i, /*0+(self.slidersView.frame.size.height-elementSize.height)*/-self.sliderRect.origin.y, elementSize.width, elementSize.height);
            
            NSString *fullResource = [page.revision.contentDirectory stringByAppendingPathComponent:element.resource];
            
            PCPageElementViewController *slideViewController = [[PCPageElementViewController alloc] initWithResource:fullResource];
            
            [slideViewController.view setFrame:newSlideRect];
            slideViewController.element = element;
            
            [slideControllers addObject:slideViewController];
            
            [self.slidersView addSubview:slideViewController.view];
            
        }
    }
    self.slideViewControllers = [NSArray arrayWithArray:slideControllers];
    
    [[self mainScrollView] bringSubviewToFront:self.slidersView];
    
//    CGRect pageControllRect = CGRectMake(sliderRect.origin.x, sliderRect.origin.y+sliderRect.size.height-30, sliderRect.size.width, 30);
//    self.pageControll = [[[PCCustomPageControll alloc] initWithFrame:pageControllRect] autorelease];
    
//    NSDictionary* controllOption = nil;
//    if (self.page.color)
//        controllOption = [NSDictionary dictionaryWithObject:self.page.color forKey:PCButtonTintColorOptionKey];
//    
//    [[PCStyler defaultStyler] stylizeElement:self.pageControll withStyleName:PCSliderPageControlItemKey withOptions:controllOption];
    
//    self.pageControll.numberOfPages = [[self.slidersView subviews] count];
//    self.pageControll.currentPage = 0;
//    [self.pageControll addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
//    [self.view addSubview:self.pageControll];
//    [self.view bringSubviewToFront:self.pageControll];
    
}

-(void)showSlideAtIndex:(NSUInteger)aSlide
{
    CGRect slidersViewRect = self.slidersView.frame;
    CGRect slideRect = CGRectMake(slidersViewRect.size.width * aSlide, 0, slidersViewRect.size.width, slidersViewRect.size.height);
    [self.slidersView scrollRectToVisible:slideRect animated:YES];
	//[self hideSlideHUD];
	//[self showHUDforSlideAtIndex:aSlide];
    
}

- (void) loadFullView
{
    [super loadFullView];
    
    //change slidersView contentSize and frame here for avoid subviews frame random changes
    if (!CGRectEqualToRect(self.sliderRect, CGRectZero))
    {
        [self.slidersView setFrame:self.sliderRect];
        
        [self.slidersView setContentSize:CGSizeMake([self.slideViewControllers count] * self.slidersView.frame.size.width,
                                                    self.slidersView.frame.size.height - 1)];
        //decrease height for avoid vertical bounce
    }
    
    for (unsigned i = 0; i < [self.slideViewControllers count]; i++)
    {
        UIViewController *slideController = [self.slideViewControllers objectAtIndex:i];
        
        CGRect newSlideRect = CGRectMake(self.view.frame.size.width * i, /*self.slidersView.frame.size.height - self.view.frame.size.height*/-self.sliderRect.origin.y, self.view.frame.size.width, self.view.frame.size.height);
        
        //        CGRect newSlideRect = CGRectMake(self.slidersView.frame.size.width * i,
        //                                         0,
        //                                         self.slidersView.frame.size.width,
        //                                         self.slidersView.frame.size.height);
        
        [slideController.view setFrame:newSlideRect];
        
    }
    
    [self updateViewsForCurrentIndex];
}

- (void) unloadFullView
{
    [super unloadFullView];
//	[self hideSlideHUD];
    
    for(PCPageElementViewController *slideViewController in self.slideViewControllers)
    {
        [slideViewController unloadView];
    }
}

- (void) updateViewsForCurrentIndex
{
//    if (self.slideViewControllers.count == 0) {
//        return;
//    }
    
//    PCPageElement* currentElement = [[self.slideViewControllers objectAtIndex:self.pageControll.currentPage] element];
//    if (currentElement && !currentElement.isComplete && self.pageControll.currentPage != 0)
//    {
//        [[NSNotificationCenter defaultCenter] postNotificationName:PCBoostPageNotification object:currentElement ];
//    }
//    
//    
//    if(self.slidersView != nil)
//    {
//        self.slidersView.scrollEnabled = YES;
//    }
//    
//    for(int i = 0; i < [self.slideViewControllers count]; ++i)
//    {
//        if(ABS(self.pageControll.currentPage - i) > 1)
//        {
//            [[self.slideViewControllers objectAtIndex:i] unloadView];
//        }
//        else
//        {
//            [[self.slideViewControllers objectAtIndex:i] loadFullViewImmediate];
//        }
//    }
}

@end
