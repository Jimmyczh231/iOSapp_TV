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

@interface ScrollableWithTitleViewController ()

@property (nonatomic, strong) CostomScrollView *pagingScrollView;

@end

@implementation ScrollableWithTitleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView *page1 = [[UIView alloc] initWithFrame:self.view.bounds];
    page1.backgroundColor = [UIColor redColor];
    
    UIView *page2 = [[UIView alloc] initWithFrame:self.view.bounds];
    page2.backgroundColor = [UIColor greenColor];
    
    UIView *page3 = [[UIView alloc] initWithFrame:self.view.bounds];
    page3.backgroundColor = [UIColor blueColor];
    
    self.pagingScrollView = [[CostomScrollView alloc] initWithFrame:self.view.bounds pages:@[page1, page2, page3]];
    [self.view addSubview:self.pagingScrollView];
    
    __weak typeof(self) weakSelf = self;
    self.pagingScrollView.didScrollToPageBlock = ^(NSInteger currentPage, CGFloat progress) {
        __strong typeof (self) strongself = weakSelf;
        NSLog(@"currentPage: %ld, progress: %.2f", (long)currentPage, progress);
        // 发送通知
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PagingScrollViewDidScrollNotification" object:nil userInfo:@{@"currentPage": @(currentPage), @"progress": @(progress)}];
    };
    self.pagingScrollView.refreshControlyes = [self createRefreshControl];
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
    

    
    [self.pagingScrollView startRefreshing];
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

@end
