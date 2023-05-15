//
//  WeiboWebViewController.m
//  迷你微博
//
//  Created by jimmy on 5/14/23.
//

#import "WeiboWebViewController.h"

@interface WeiboWebViewController ()

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) NSURL *url;

@end

@implementation WeiboWebViewController

- (instancetype)initWithURL:(NSURL*)URL{
    self = [super init];
    if (self) {
        self.url = URL;
    }
    return self;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.webView = [[WKWebView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [self loadWebViewWithURL:self.url];
}

- (void)loadWebViewWithURL:(NSURL *)url {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        dispatch_async(dispatch_get_main_queue(), ^{
            // 在这里执行需要更新UI的代码、
            [self.webView loadRequest:request];
            [self.view addSubview:self.webView];
        });
    });
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
