//
//  CostomScrollView.m
//  迷你微博
//
//  Created by jimmy on 5/10/23.
//

#import "CostomScrollView.h"






#define kRefreshControlHeight 80.0
#define kLoadMoreControlHeight 80.0

@interface CostomScrollView () <UIScrollViewDelegate>


@property (nonatomic, assign) BOOL isDragging;
@property (nonatomic, assign) BOOL isRefreshing;
@property (nonatomic, assign) BOOL isLoadingMore;
@property (nonatomic, assign) BOOL shouldAllowRefresh;
@property (nonatomic, assign) BOOL shouldAllowLoadMore;
@property (nonatomic, assign) CGPoint beginContentOffset;
@property (nonatomic, strong) NSMutableArray<UILabel *> *refreshControllLabels;
@property (nonatomic, strong) NSMutableArray<UILabel *> *loadMoreControllLabels;

@end

@implementation CostomScrollView

- (instancetype)initWithFrame:(CGRect)frame pages:(NSArray *)pages {
    self = [super initWithFrame:frame];
    if (self) {
        self.pagingEnabled = YES;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.bounces = NO;
        self.delegate = self;
        self.refreshControllLabels = [NSMutableArray array];
        self.loadMoreControllLabels = [NSMutableArray array];
        self.pages = pages;
        self.currentPage = 0;
        
        // 添加每一页的视图并设置frame
        for (NSInteger i = 0; i < pages.count; i++) {
            UIView *pageView = pages[i];

            pageView.frame = CGRectMake(i * frame.size.width, kRefreshControlHeight+50, frame.size.width, frame.size.height-kRefreshControlHeight-100);
            // 添加刷新条
//            UIView * refreshControls = [[UIView alloc] initWithFrame:CGRectMake(i * frame.size.width, 0, frame.size.width, kRefreshControlHeight)];
//            refreshControls.userInteractionEnabled = NO;
//            refreshControls.backgroundColor = [UIColor whiteColor];
//            UILabel *label = [[UILabel alloc] initWithFrame:refreshControls.bounds];
//            label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y + 60, label.frame.size.width, label.frame.size.height-30);
//            label.textAlignment = NSTextAlignmentCenter;
//            label.text = @"下拉刷新";
//            [self.refreshControllLabels addObject:label];
//            [refreshControls addSubview:self.refreshControllLabels[i]];

            // 添加加载更多条
//            UIView *loadMoreView = [[UIView alloc] initWithFrame:CGRectMake(i * frame.size.width, frame.size.height - 40, frame.size.width, 100)];
//            loadMoreView.backgroundColor = [UIColor whiteColor];
//            UILabel *loadMoreLabel = [[UILabel alloc] initWithFrame:loadMoreView.bounds];
//            loadMoreLabel.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y - 50, label.frame.size.width, label.frame.size.height-30);
//            loadMoreLabel.textAlignment = NSTextAlignmentCenter;
//            loadMoreLabel.text = @"加载更多";
//            loadMoreLabel.textColor = [UIColor orangeColor];
//            [self.loadMoreControllLabels addObject:loadMoreLabel];
//            [loadMoreView addSubview:loadMoreLabel];
            
//            [self addSubview:refreshControls];
            [self addSubview:pageView];
//            [self addSubview:loadMoreView];
            
        }
        
        // 设置contentSize 为所有页面宽度的总和，高度等于 scrollView 高度加上 tabbar 长度
        self.contentSize = CGSizeMake(frame.size.width * pages.count, frame.size.height+20);
        

    }
    return self;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // 如果正在刷新，禁止滑动
//    if (self.isRefreshing && !self.isDragging) {
//        scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, -kRefreshControlHeight);
//        return;
//    }
    CGPoint currentContentOffset = scrollView.contentOffset;
    CGFloat deltaX = currentContentOffset.x - self.beginContentOffset.x;
    CGFloat deltaY = currentContentOffset.y - self.beginContentOffset.y;
    
    // 根据滑动方向限制滑动
    if (fabs(deltaX) > fabs(deltaY)) {
        // 水平滑动
        scrollView.contentOffset = CGPointMake(currentContentOffset.x, self.beginContentOffset.y);
    } else {
        // 垂直滑动
        scrollView.contentOffset = CGPointMake(self.beginContentOffset.x, currentContentOffset.y);
    }
    
   
    // 判断是否滑动到边界，禁止继续滑动
    CGPoint offset = scrollView.contentOffset;
    if (scrollView.contentOffset.x <= 0 || scrollView.contentOffset.x > scrollView.contentSize.width - scrollView.bounds.size.width) {
        // 禁止左右滑动
        if (scrollView.contentOffset.x <= 0) {
            offset.x = 0;
        } else {
            offset.x = scrollView.contentSize.width - scrollView.bounds.size.width;
        }
        scrollView.contentOffset = offset;
    }
    
    // 禁止上下滑动
    if(scrollView.contentOffset.y != 0) {
        offset.y = 0;
        scrollView.contentOffset = offset;
    }
    
    // 计算并发送滑动进度
    CGFloat pageWidth = scrollView.frame.size.width;
    CGFloat pageHeight = scrollView.frame.size.height;
    CGFloat progress = (scrollView.contentOffset.x - pageWidth * self.currentPage) / pageWidth;
    self.currentPage = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    // 如果有设置didScrollToPageBlock，调用它并传递currentPage和progress
    if (self.didScrollToPageBlock) {
        if (progress > 1) {
            self.currentPage += 1;
            progress -= 1;
        } else if (progress < -1) {
            self.currentPage -= 1;
            progress += 1;
        }
        self.didScrollToPageBlock(self.currentPage, progress);
    }
    
//    // 判断是否滑动到边界，禁止继续滑动
//    if (scrollView.contentOffset.x <= 0 || scrollView.contentOffset.x >= scrollView.contentSize.width - scrollView.frame.size.width) {
//        scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y);
//    }
    
    // 下拉刷新的分段设置
//    if (scrollView.contentOffset.y <= -kRefreshControlHeight / 2 - 20  && self.shouldAllowRefresh && !self.isRefreshing) {
//        (self.refreshControllLabels[self.currentPage]).text = @"松开刷新";
//    } else if (scrollView.contentOffset.y > -kRefreshControlHeight / 2 - 20  && self.shouldAllowRefresh && !self.isRefreshing){
//        (self.refreshControllLabels[self.currentPage]).text = @"下拉刷新";
//    }
    
    // 上滑加载的分段设置
//    if (scrollView.contentOffset.y + scrollView.frame.size.height >= scrollView.contentSize.height + 65  && self.shouldAllowLoadMore && !self.isLoadingMore) {
//        (self.loadMoreControllLabels[self.currentPage]).text = @"松开加载";
//    } else if (scrollView.contentOffset.y + scrollView.frame.size.height < scrollView.contentSize.height + 65  && self.shouldAllowLoadMore && !self.isLoadingMore){
//        (self.loadMoreControllLabels[self.currentPage]).text = @"加载更多";
//    }

    NSLog(@"%lf",scrollView.contentOffset.y);
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat pageWidth = scrollView.frame.size.width;
    self.currentPage = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    if(!self.isRefreshing && !self.isLoadingMore){
        // 迅速移动到最近的页面
        [self setContentOffset:CGPointMake(self.currentPage * pageWidth, 0) animated:YES];
    }

    // 发送一次页面消息，使字体发生变化
    CGFloat progress = (scrollView.contentOffset.x - pageWidth * self.currentPage) / pageWidth;
    // 如果有设置didScrollToPageBlock，调用它并传递currentPage和progress
    if (self.didScrollToPageBlock) {
        if (progress > 1) {
            self.currentPage += 1;
            progress -= 1;
        } else if (progress < -1) {
            self.currentPage -= 1;
            progress += 1;
        }
        self.didScrollToPageBlock(self.currentPage, progress);
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    // 记录 scrollView 的拖拽状态
    self.isDragging = YES;
    // 重置跳转到最近页面
    self.pagingEnabled = YES;
    
    // 记录 scrollView 的滚动方向
    CGPoint velocity = [scrollView.panGestureRecognizer velocityInView:self];
    self.beginContentOffset = scrollView.contentOffset;
    if (fabs(velocity.x) > fabs(velocity.y)) {
        // 左右滑动，禁止下拉刷新和上滑添加
        self.shouldAllowRefresh = NO;
        self.shouldAllowLoadMore = NO;
        self.pagingEnabled = YES;

    } else {
        // 上下滑动，允许下拉刷新和上滑添加
        self.shouldAllowRefresh = YES;
        self.shouldAllowLoadMore = YES;
    }
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    self.isDragging = NO;
    
    // 如果下拉刷新控件已经显示超过位置，触发刷新
    if (scrollView.contentOffset.y <= -kRefreshControlHeight / 2 - 20  && self.shouldAllowRefresh) { //
        self.pagingEnabled = NO;
        [self startRefreshing];

    }
    
    // 如果上滑加载控件已经显示超过位置，触发加载更多
    if (scrollView.contentOffset.y + scrollView.frame.size.height >= scrollView.contentSize.height + 65 && self.shouldAllowLoadMore) {
        self.pagingEnabled = NO;
        [self startLoadingMore];
    }

    CGFloat pageWidth = scrollView.frame.size.width;
    if(!self.isRefreshing && ((scrollView.contentOffset.x - pageWidth * self.currentPage) / pageWidth )== 0){
        CGFloat pageWidth = self.frame.size.width;
        // 根据 scrollView 的 contentOffset 计算当前页面
        self.currentPage = floor((self.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        // 迅速移动到最近的页面
        [self setContentOffset:CGPointMake(self.currentPage * pageWidth, 0) animated:YES];
    }
    

    
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    // 如果正在刷新，禁止滑动
//    if (self.isRefreshing) {
//        scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, -kRefreshControlHeight);
//        return;
//    }
}

- (void)setCurrentPage:(NSInteger)currentPage {
    if (_currentPage != currentPage) {
        _currentPage = currentPage;
        // 如果有设置didSelectPageBlock，调用它并传递currentPage
        if (self.didSelectPageBlock) {
            self.didSelectPageBlock(currentPage);
        }
    }
}

- (void)startRefreshing {
//    // 设置控件文字
//    (self.refreshControllLabels[self.currentPage]).text = @"正在刷新";
//    // 如果任然在滑动，就不刷新
//    if (self.isDragging) {
//        return;
//    }
//    self.isRefreshing = YES;
//    // 显示出完整的控件
//    [self setContentOffset:CGPointMake(self.contentOffset.x, -kRefreshControlHeight) animated:YES];
//    // 调用 block 刷新数据
//    if (self.refreshBlock) {
//        self.refreshBlock();
//    }

}

- (void)endRefreshing {
//    CGFloat pageWidth = self.frame.size.width;
//    // 根据scrollView的contentOffset计算当前页面
//    self.currentPage = floor((self.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
//    // 迅速移动到最近的页面
//    if (self.isRefreshing) {
//    [self setContentOffset:CGPointMake(self.currentPage * pageWidth, 0) animated:YES];
//    self.isRefreshing = NO;
//    }
//
}

- (void)startLoadingMore {
    // 设置控件文字
    (self.loadMoreControllLabels[self.currentPage]).text = @"正在加载";
    // 如果任然在滑动，就不加载
    if (self.isDragging) {
            return;
    }
    self.isLoadingMore = YES;
    // 显示出完整的控件
    CGFloat contentHeight = self.contentSize.height+kRefreshControlHeight;
    CGFloat height = CGRectGetHeight(self.frame);
    CGFloat offsetY = self.contentOffset.y;
    CGFloat maxOffsetY = contentHeight - height;
    [self setContentOffset:CGPointMake(self.contentOffset.x, maxOffsetY) animated:YES];
    // 调用 block 加载更多数据
    if (self.loadMoreBlock) {
            self.loadMoreBlock();
    }
}
//
- (void)endLoadingMore {
    CGFloat pageWidth = self.frame.size.width;
    // 根据scrollView的contentOffset计算当前页面
    self.currentPage = floor((self.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    // 迅速移动到最近的页面
    if (self.isLoadingMore) {
    [self setContentOffset:CGPointMake(self.currentPage * pageWidth, 0) animated:YES];
    self.isLoadingMore = NO;
    }
}


@end

