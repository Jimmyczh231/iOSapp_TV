//
//  WeiboOAuthHelper.m
//  迷你微博
//
//  Created by jimmy on 5/11/23.
//

#define Appkey @"2262783794"
#define Redirect_Uri @"http://localhost/com.jimmyczh.jimmy"

#import "WeiboOAuthHelper.h"
#import "AccessToken.h"
#import "SceneDelegate.h"

@interface WeiboOAuthHelper()

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, copy) void (^completion)(NSString * _Nullable accessToken, NSError * _Nullable error);

@end

@implementation WeiboOAuthHelper

- (instancetype)initWithCompletion:(void (^)(NSString * _Nullable accessToken, NSError * _Nullable error))completion {
    self = [super init];
    if (self) {
        self.completion = completion;
    }
    return self;
}

- (void)authorize {
    self.webView = [[WKWebView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.webView.navigationDelegate = self;
    UIViewController *vc = [[UIViewController alloc] init];
    vc.view.frame = [[UIScreen mainScreen] bounds];
    [vc.view addSubview: self.webView];
    NSArray *connectedScenes = [[UIApplication sharedApplication].connectedScenes allObjects];
    UIWindowScene *windowScene = (UIWindowScene *)connectedScenes[0];
    SceneDelegate* allDelegate = windowScene.delegate;
    UINavigationController* navVC = allDelegate.window.rootViewController;
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.weibo.com/oauth2/authorize?client_id=%@&response_type=code&redirect_uri=%@", self.clientID, self.redirectURI]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    [navVC pushViewController:vc animated:YES];
    

}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSURL *url = navigationAction.request.URL;
    if ([url.absoluteString containsString:@"code="]) {
        NSString *code = [self extractCodeFromURL:url];
        [self requestAccessTokenWithCode:code];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    } else if ([url.absoluteString containsString:@"error_code"]) {
        NSError *error = [self extractErrorFromURL:url];
        if (self.completion) {
            self.completion(nil, error);
        }
        [self closeWebView];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (NSString *)extractCodeFromURL:(NSURL *)url {
    NSString *query = url.query;
    NSArray *components = [query componentsSeparatedByString:@"="];
    if (components.count == 2 && [components[0] isEqualToString:@"code"]) {
        return components[1];
    }
    return nil;
}

- (NSError *)extractErrorFromURL:(NSURL *)url {
    NSString *query = url.query;
    NSArray *components = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    for (NSString *component in components) {
        NSArray *pair = [component componentsSeparatedByString:@"="];
        if (pair.count == 2) {
            [userInfo setObject:pair[1] forKey:pair[0]];
        }
    }
    NSError *error = [NSError errorWithDomain:@"WeiboOAuthHelperErrorDomain" code:-1 userInfo:userInfo];
    return error;
}

- (void)requestAccessTokenWithCode:(NSString *)code {
    NSURL *url = [NSURL URLWithString:@"https://api.weibo.com/oauth2/access_token"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    NSString *body = [NSString stringWithFormat:@"client_id=%@&client_secret=%@&grant_type=authorization_code&code=%@&redirect_uri=%@", self.clientID, self.clientSecret, code, self.redirectURI];
    request.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            if (self.completion) {
                self.completion(nil, error);
            }
            [self closeWebView];
            return;
        }
        NSError *jsonError = nil;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        if (jsonError) {
            if (self.completion) {
                self.completion(nil, jsonError);
            }
            [self closeWebView];
            return;
        }
        NSString *accessToken = json[@"access_token"];
        if (self.completion) {
            self.completion(accessToken, nil);
            [[AccessToken sharedInstance] setAccessToken:accessToken];
        }
        [self closeWebView];
    }];
    [task resume];
}

- (void)closeWebView {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.webView removeFromSuperview];
        self.webView = nil;
    });
}

@end
