//
//  testviewcontroller.m
//  迷你微博
//
//  Created by jimmy on 5/11/23.
//

#import "testviewcontroller.h"
#import "WeiboOAuthViewController.h"
#import "WeiboOAuthHelper.h"
#import <WebKit/WebKit.h>
@interface testviewcontroller () <WKNavigationDelegate>

@property (nonatomic, strong) WKWebView *webView;

@end

@implementation testviewcontroller

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    WeiboOAuthViewController *oauthHelper = [[WeiboOAuthViewController alloc] initWithCompletion:^(NSString * _Nullable accessToken, NSError * _Nullable error) {
        if (accessToken) {
            // 授权成功，获取到 accessToken
            NSLog(@"Access token: %@", accessToken);
        } else {
            // 授权失败，打印错误信息
            NSLog(@"Error: %@", error);
        }
    }];

    oauthHelper.clientID = @"2262783794";
    oauthHelper.clientSecret = @"53e0114ec2ec768df43bf3f7d10f4bab";
    oauthHelper.redirectURI = @"http://localhost/com.jimmyczh.jimmy";
    oauthHelper.pushViewController = self;
    [self.navigationController pushViewController:oauthHelper animated:YES];
//    [oauthHelper authorize];
    
//    self.webView = [[WKWebView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//    self.webView.navigationDelegate = self;
//
//
//    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.weibo.com/oauth2/authorize?client_id=%@&response_type=code&redirect_uri=%@", oauthHelper.clientID, oauthHelper.redirectURI]];
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//    [self.webView loadRequest:request];
//    self.navigationController pushViewController:<#(nonnull UIViewController *)#> animated:<#(BOOL)#>;
    

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
