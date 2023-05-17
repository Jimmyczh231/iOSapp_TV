//
//  ScrollableWithTitleViewController.m
//  迷你微博
//
//  Created by jimmy on 5/10/23.
//
#define kRefreshControlHeight 50.0
#define kLoadMoreControlHeight 50.0


#import "ScrollableWithTitleViewController.h"
#import "CostomScrollView.h"
#import "CostomScrollViewBar.h"
#import "weiboSenderViewController.h"
#import "HomePageTableViewController.h"
#import "AccessToken.h"
#import "WeiboOAuthViewController.h"
#import "WeiboWebViewController.h"


@interface ScrollableWithTitleViewController ()<HomePageTableViewControllerDelegate>

@property (nonatomic, strong) CostomScrollView *pagingScrollView;
@property (nonatomic, strong) CostomScrollViewBar *ScrollViewBar;
@property (nonatomic, strong) weiboSenderViewController *weiboSenderView;
@property (nonatomic, strong) HomePageTableViewController *homePageTable;
@property (nonatomic, strong, readwrite) WeiboWebViewController *webViewController;

@property (nonatomic, strong) NSMutableArray *allViewArray;
@property (nonatomic, readwrite) NSInteger currnetPage;
@property (nonatomic, readwrite) CGFloat progress;
@end

@implementation ScrollableWithTitleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.userInteractionEnabled = YES;
    self.ScrollViewBar = [[CostomScrollViewBar alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 120.0)];

    self.homePageTable = [[HomePageTableViewController alloc] init];
    self.homePageTable.delegate = self;
    
    UIView *page1 = [[UIView alloc] initWithFrame:self.view.bounds];
    page1.backgroundColor = [UIColor redColor];
    
    UIView *page2 = [[UIView alloc] initWithFrame:self.view.bounds];
    page2.backgroundColor = [UIColor greenColor];
    
    UIView *page3 = [[UIView alloc] initWithFrame:self.view.bounds];
    page3.backgroundColor = [UIColor blueColor];
    self.allViewArray = [NSMutableArray array];
    [self.allViewArray addObject:page1];
    [self.allViewArray addObject:self.homePageTable.tableView];
    [self.allViewArray addObject:page3];
    self.pagingScrollView = [[CostomScrollView alloc] initWithFrame:self.view.bounds pages:@[page1, self.homePageTable.tableView, page3]];
    
    __weak typeof(self) weakSelf = self;
    self.pagingScrollView.didScrollToPageBlock = ^(NSInteger currentPage, CGFloat progress) {
        __strong typeof (self) strongself = weakSelf;
        NSLog(@"currentPage: %ld, progress: %.2f", (long)currentPage, progress);
        // 发送通知
        if (progress == 0) {
            if (currentPage == 1) {
                strongself.currnetPage = currentPage;
                strongself.progress = progress;
                [strongself.homePageTable refreshTableView];
            }
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PagingScrollViewDidScrollNotification" object:nil userInfo:@{@"currentPage": @(currentPage), @"progress": @(progress)}];
    };
//    self.pagingScrollView.refreshControlyes = [self createRefreshControl];
//    self.pagingScrollView.loadMoreControlyes = [self createLoadMoreControl];
//    self.pagingScrollView.loadMoreBlock = ^{
//        __strong typeof (self) strongself = weakSelf;
//        [strongself loadMoreData];
//    };
    self.pagingScrollView.refreshBlock = ^{
        __strong typeof (self) strongself = weakSelf;
        [strongself loadNewData];
    };
    self.pagingScrollView.loadMoreBlock  = ^{
        __strong typeof (self) strongself = weakSelf;
        [strongself loadMoreData];
    };

    [self.view addSubview:self.pagingScrollView];
    [self.view addSubview:self.ScrollViewBar];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *senderImage = [UIImage imageNamed:@"jiahao.png"];
    UIImage *senderImageTouched = [UIImage imageNamed:@"jiahao-2.png"];
    button.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 50, 80, 28, 28);
    [button setImage:senderImage forState:UIControlStateNormal];
    [button setImage:senderImageTouched forState:UIControlStateSelected];
    [button setTitle:@"Button Title" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [button becomeFirstResponder];

    [self.view addSubview:button];
    
    // 创建 UITapGestureRecognizer 对象
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonTapped:)];
    // 将 tapGestureRecognizer 添加到你的 view 上
    [self.ScrollViewBar addGestureRecognizer:tapGestureRecognizer];

    
    [self.pagingScrollView startRefreshing];
    [button becomeFirstResponder];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOpenURLNotification:) name:@"OpenURLNotification" object:nil];

    
}

- (void)handleOpenURLNotification:(NSNotification *)notification {
    NSURL *url = notification.userInfo[@"url"];
    self.webViewController = [[WeiboWebViewController alloc]initWithURL:url];
    [self.navigationController pushViewController:self.webViewController animated:YES];

}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"OpenURLNotification" object:nil];
}


- (UIView *)createRefreshControl {
    UIView *refreshControl = [[UIView alloc] initWithFrame:CGRectMake(0, -kRefreshControlHeight, self.view.bounds.size.width, kRefreshControlHeight)];
    refreshControl.backgroundColor = [UIColor whiteColor];
    UILabel *label = [[UILabel alloc] initWithFrame:refreshControl.bounds];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"下拉刷新";
    [refreshControl addSubview:label];
    return refreshControl;
}

- (IBAction)buttonTapped:(UIButton *)sender {
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"你点击了按钮" preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
//    [alert addAction:okAction];
//    [self presentViewController:alert animated:YES completion:nil];
    self.weiboSenderView = [[weiboSenderViewController alloc]init];
    [self.navigationController pushViewController:self.weiboSenderView animated:YES];
}

- (void)loadNewData {
    // 实现刷新数据的逻辑
    if (self.progress == 0) {
        if(self.currnetPage == 1) {
            self.homePageTable.needToRefresh = YES;
            [self.homePageTable refreshTableView];
        }
        
    }
    
    // 刷新结束后需要调用endRefreshing方法停止下拉刷新
    [self.pagingScrollView endRefreshing];
}

- (void)loadMoreData {
    // 实现加载更多数据的逻辑
    if (self.progress == 0) {
        if(self.currnetPage == 1) {
            [self.homePageTable loadMoreDataOnTableView];
        }
        
    }
}

- (void)viewDidAppear:(BOOL)animated{
    if([AccessToken sharedInstance].accessToken == nil){
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
    }
    
}
- (void)presentWeiboDetailWith:(nonnull NSDictionary *)status {
    NSURL *url;
    NSString * urlHead;
    urlHead = @"http://api.weibo.com/2/statuses/go";


    // 添加请求参数
    NSString *params;
    if ([AccessToken sharedInstance].accessToken != nil){
        params = [NSString stringWithFormat:@"access_token=%@&uid=%@&id=%@", [AccessToken sharedInstance].accessToken, [[status objectForKey:@"user"]objectForKey:@"id"], [status objectForKey:@"id"]];
        
    }else{
//        params = [NSString stringWithFormat:@"count=%d&page=%@", kWeiboDataCount, self.nextPageCursor];
    }
    NSString *fullUrlString = [NSString stringWithFormat:@"%@?%@", urlHead, params];
    url = [NSURL URLWithString:fullUrlString];
    self.webViewController = [[WeiboWebViewController alloc]initWithURL:url];
    [self.navigationController pushViewController:self.webViewController animated:YES];
}
//- (UIView *)createLoadMoreControl {
//    UIView *loadMoreControl = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, kLoadMoreControlHeight)];
//    loadMoreControl.backgroundColor = [UIColor whiteColor];
//    UILabel *label = [[UILabel alloc] initWithFrame:loadMoreControl.bounds];
//    label.textAlignment = NSTextAlignmentCenter;
//    label.text = @"上拉加载更多";
//    [loadMoreControl addSubview:label];
//    return loadMoreControl;
//}

//- (void)loadMoreData {
//    // 实现刷新数据的逻辑
//    // ...
//    // 刷新结束后需要调用endRefreshing方法停止下拉刷新
//
//    [self.pagingScrollView endLoadingMore];
//}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/









@end
