//
//  RueFacebookController
//  padCMS
//
//  Created by Martyniuk.M on 10/16/13.
//  Copyright (c) 2013 DBBest. All rights reserved.
//

#import "RueFacebookController.h"
#import <Social/Social.h>
#import "NSObject+Block.h"
#import "NSURL+Fragments.h"
#import "FacebookPostConfirmView.h"

//#define kFacebookAppId @"217375451760338"

@interface RueFacebookController () <UIWebViewDelegate>
{
    NSString* _postString;
    NSURL* _postUrl;
    NSURL* _pictureUrl;
    NSString* _postDescription;
}
@property (nonatomic, strong) UIWebView* webView;
@property (nonatomic, strong) FacebookPostConfirmView* confirmView;

@property (nonatomic, copy) void(^finishLoadBlock)(UIView* dialogView);
@property (nonatomic, copy) void(^tokenTaken)(UIView *authorizationView, UIView* confirmPostView);
@property (nonatomic, copy) void (^postComplete)(UIView *, NSError*);
@property (nonatomic, strong) NSString* token;

@end

@implementation RueFacebookController

static NSString* kFacebookAppId = nil;

+ (void) initialize
{
    NSDictionary* plist = [[NSBundle mainBundle]infoDictionary];
    kFacebookAppId = plist[@"PADCMSConfig"][@"PCConfigFacebookId"];
}

+ (void) postEmbeddedText:(NSString*)postText url:(NSURL*)postUrl image:(UIImage*)postImage inController:(UIViewController*)controller completionHandler:(void(^)(BOOL success, NSError* error))completionBlock
{
    SLComposeViewController *composerSheet = [[SLComposeViewController alloc] init];
    composerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    
    [composerSheet setInitialText:postText];
    [composerSheet addURL:postUrl];
    [composerSheet addImage:postImage];
    
    [controller presentViewController:composerSheet animated:YES completion:^{
        
        if(completionBlock) completionBlock(YES, nil);
        
    }];
}

+ (BOOL) canPostEmbedded
{
    return ([[[UIDevice currentDevice]systemVersion]floatValue] >= 6.0 && [SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]);
}

- (id) initWithMessage:(NSString*)message url:(NSURL*)url
{
    return [self initWithMessage:message url:url pictureLink:nil description:nil];
}

- (id) initWithMessage:(NSString*)message url:(NSURL*)url pictureLink:(NSURL*)pictureLink
{
    return [self initWithMessage:message url:url pictureLink:pictureLink description:nil];
}
- (id) initWithMessage:(NSString*)message url:(NSURL*)url pictureLink:(NSURL*)pictureLink description:(NSString*)description
{
    self = [super init];
    if(self)
    {
        _needToConfirmPost = YES;
        _postString = message;
        _postUrl = url;
        if(description)
        {
            _postDescription = [description stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
        _pictureUrl = pictureLink;
        [self cleareCookie];
    }
    return self;
}

- (void) shareWithDialog:(void(^)(UIView*dialogView))authorizeDialog authorizationComplete:(void (^)(UIView *authorizationView, UIView* confirmPostView))confirmPostBlock postComplete:(void (^)(UIView *, NSError*))postCompleteBlock
{
    UIWebView* webView = [[UIWebView alloc]init];
    webView.scalesPageToFit = YES;
    webView.autoresizesSubviews = YES;
    webView.clipsToBounds = YES;
    webView.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    self.webView = webView;
    webView.delegate = self;
    
    self.finishLoadBlock = authorizeDialog;
    self.tokenTaken = confirmPostBlock;
    self.postComplete = postCompleteBlock;
    
    NSMutableString* urlString = [NSMutableString stringWithString:@"https://www.facebook.com/dialog/oauth"];
    
    NSString* params = [NSString stringWithFormat:@"redirect_uri=http://www.facebook.com/connect/login_success.html&response_type=token&client_id=%@&scope=email,read_stream,read_requests,xmpp_login,user_location,user_checkins,user_activities,publish_stream,user_about_me&auth_type=https", kFacebookAppId];
    
    [urlString appendFormat:@"?%@", params];
    NSURL* requestUrl = [[NSURL alloc]initWithString:urlString];
    NSURLRequest* request = [[NSURLRequest alloc]initWithURL:requestUrl cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:5];
    [self.webView loadRequest:request];
}

- (UIView*) confirmPostViewCreate
{
    self.confirmView = [[[NSBundle mainBundle]loadNibNamed:@"FacebookPostConfirmView" owner:nil options:nil]lastObject];
    self.confirmView.postMessage = _postString;
    self.confirmView.postLink = _postUrl.absoluteString;
    [self.confirmView setPostAction:@selector(post) target:self];
    return self.confirmView;
}

- (void) post
{
    [self.confirmView setBlockedButton:YES];
    
    [self sendPostRequestWithSuccessBlock:^{
        
        [self.confirmView showSuccessWithComplition:^{
            
            if(self.postComplete)
            {
                self.postComplete(self.confirmView, nil);
                self.postComplete = nil;
            }
        }];
        
    } errorBlock:^(NSError *error) {
        
        [self.confirmView showError:error];
    }];
}

- (void) sendPostRequestWithSuccessBlock:(void(^)())successBlock errorBlock:(void(^)(NSError*))errorBlock
{
    NSMutableString* urlString = [NSMutableString stringWithString:@"https://graph.facebook.com/me/feed"];
    NSURL* requestUrl = [[NSURL alloc]initWithString:urlString];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc]initWithURL:requestUrl];
    
    NSString* postString = self.confirmView ? self.confirmView.postMessage : _postString;
    
    //    picture=%@
    //      description
    NSMutableString* paramsString = [NSMutableString stringWithFormat:@"access_token=%@&message=%@&link=%@", self.token, postString, _postUrl.absoluteString];
    if(_pictureUrl)
    {
        [paramsString appendFormat:@"&picture=%@", [_pictureUrl.absoluteString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    if(_postDescription)
    {
        [paramsString appendFormat:@"&description=%@", _postDescription];
    }
    request.HTTPMethod = @"POST";
    
    request.HTTPBody = [paramsString dataUsingEncoding:NSUTF8StringEncoding];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue]  completionHandler:^(NSURLResponse *responce, NSData *data, NSError *error) {
        
        if(error)
        {
            NSLog(@"Connection error : %@", error.localizedDescription);
            if(errorBlock) errorBlock(error);
        }
        else
        {
            NSDictionary* result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            
            NSDictionary* errorDic = result[@"error"];
            
            if(errorDic)
            {
                NSError* err = [NSError errorWithDomain:@"facebook" code:[errorDic[@"code"] intValue] userInfo:@{NSLocalizedDescriptionKey : errorDic[@"message"]}];
                if(errorBlock) errorBlock(err);
            }
            else
            {
                if(successBlock) successBlock();
            }
        }
    }];
}

- (void) tokenReceived:(NSString*)token
{
    self.token = token;
    
    if(self.needToConfirmPost)
    {
        if(self.tokenTaken)
        {
            self.tokenTaken(self.webView, [self confirmPostViewCreate]);
            self.tokenTaken = nil;
        }
    }
    else
    {
        if(self.tokenTaken)
        {
            self.tokenTaken = nil;
        }
        if(self.postComplete)
        {
            self.postComplete(self.webView, nil);
            self.postComplete = nil;
        }
        [self sendPostRequestWithSuccessBlock:nil errorBlock:nil];
    }
}


- (void) cleareCookie
{
    static NSString* facebookDomain = @".facebook.com";
    
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie* cookie  in [cookieJar cookies])
    {
        if([cookie.domain isEqualToString:facebookDomain])
        {
            [cookieJar deleteCookie:cookie];
        }
    }
}

#pragma mark - WebViewDelegate Protocol

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    static NSString* cancelRedirectPath = @"/connect/login_success.html";
    
    if([request.URL.path isEqualToString:cancelRedirectPath])//operation complete
    {
        NSDictionary* redirectParams = request.URL.queryFragments;
        
        NSString* token = redirectParams[@"access_token"];
        if(token && token.length > 0)
        {
            [self tokenReceived:token];
        }
        return NO;
    }
    return YES;
}

- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    if(self.finishLoadBlock)
    {
        self.finishLoadBlock(webView);
        self.finishLoadBlock = nil;
    }
}

@end
