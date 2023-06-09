//
//  WeiboOAuthViewController.m
//  迷你微博
//
//  Created by jimmy on 5/11/23.
//

#import "WeiboOAuthViewController.h"
#import "AccessToken.h"

@interface WeiboOAuthViewController ()


@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, copy) void (^completion)(NSString * _Nullable accessToken, NSError * _Nullable error);


@end

@implementation WeiboOAuthViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self authorize];
}

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

    [self.view addSubview: self.webView];

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.weibo.com/oauth2/authorize?client_id=%@&response_type=code&redirect_uri=%@", self.clientID, self.redirectURI]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    // 通过请求后跳转的网址，进一步获取 token
    NSURL *url = navigationAction.request.URL;
    if ([url.absoluteString containsString:@"code="]) {
        // 如果返回了 code，使用它请求 token
        NSString *code = [self extractCodeFromURL:url];
        [self requestAccessTokenWithCode:code];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    } else if ([url.absoluteString containsString:@"error_code"]) {
        // 失败
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
    // 从返回的 URL 中获得 code
    NSString *query = url.query;
    NSArray *components = [query componentsSeparatedByString:@"="];
    if (components.count == 2 && [components[0] isEqualToString:@"code"]) {
        return components[1];
    }
    return nil;
}

- (NSError *)extractErrorFromURL:(NSURL *)url {
    // 从返回的 URL 中获取报错信息
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
    // 通过前面获取的 code，请求 token
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
        NSString *uid = json[@"uid"];
        if (self.completion) {
            self.completion(accessToken, nil);
            if([AccessToken sharedInstance].accessToken == nil){
                // token 存入单列对象，方便在所有地方使用
                [[AccessToken sharedInstance] setAccessToken:accessToken];
                [[AccessToken sharedInstance] setUid:uid];
            }
        }
        [self closeWebView];
    }];
    [task resume];
}

- (void)closeWebView {
    dispatch_async(dispatch_get_main_queue(), ^{
        // 关闭登陆界面
        [self.webView removeFromSuperview];
        self.webView = nil;
        [self.navigationController popViewControllerAnimated:YES];
    });
}


@end
