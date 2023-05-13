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
@interface ScrollableWithTitleViewController ()<CostomScrollViewBarDelegate>

@property (nonatomic, strong) CostomScrollView *pagingScrollView;
@property (nonatomic, strong) CostomScrollViewBar *ScrollViewBar;
@property (nonatomic, strong) weiboSenderViewController *weiboSenderView;

@end

@implementation ScrollableWithTitleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.userInteractionEnabled = YES;
    self.ScrollViewBar = [[CostomScrollViewBar alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 120.0)];
    self.ScrollViewBar.delegate = self;
    
    UIView *page1 = [[UIView alloc] initWithFrame:self.view.bounds];
    page1.backgroundColor = [UIColor redColor];
    
    UIView *page2 = [[UIView alloc] initWithFrame:self.view.bounds];
    page2.backgroundColor = [UIColor greenColor];
    
    UIView *page3 = [[UIView alloc] initWithFrame:self.view.bounds];
    page3.backgroundColor = [UIColor blueColor];
    
    self.pagingScrollView = [[CostomScrollView alloc] initWithFrame:self.view.bounds pages:@[page1, page2, page3]];
    
    __weak typeof(self) weakSelf = self;
    self.pagingScrollView.didScrollToPageBlock = ^(NSInteger currentPage, CGFloat progress) {
        __strong typeof (self) strongself = weakSelf;
        NSLog(@"currentPage: %ld, progress: %.2f", (long)currentPage, progress);
        // 发送通知
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

    // 设置 frame 属性
//    button.frame = CGRectMake(100, 100, 100, 50);
    // 添加到视图中
    [self.view addSubview:button];
    // 创建 UITapGestureRecognizer 对象
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonTapped:)];
    // 将 tapGestureRecognizer 添加到你的 view 上
    [self.ScrollViewBar addGestureRecognizer:tapGestureRecognizer];

    
    [self.pagingScrollView startRefreshing];
    [button becomeFirstResponder];
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
    // ...
    // 刷新结束后需要调用endRefreshing方法停止下拉刷新
    
    [self.pagingScrollView endRefreshing];
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

- (void)WeiboSenderPush {
    
}



@end
