//
//  CostomScrollView.m
//  迷你微博
//
//  Created by jimmy on 5/10/23.
//

#import "CostomScrollView.h"






#define kRefreshControlHeight 80.0
#define kLoadMoreControlHeight 50.0

@interface CostomScrollView () <UIScrollViewDelegate>


@property (nonatomic, assign) BOOL isDragging;
@property (nonatomic, assign) BOOL isRefreshing;
@property (nonatomic, assign) BOOL isLoadingMore;
@property (nonatomic, assign) BOOL shouldAllowRefresh;
@property (nonatomic, assign) BOOL shouldAllowLoadMore;
@property (nonatomic, assign) CGPoint beginContentOffset;
@property (nonatomic, strong) NSMutableArray<UILabel *> *refreshControllLabels;
@property (nonatomic, strong) NSMutableArray<UIView *> *refreshControlls;

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
        self.pages = pages;
        self.currentPage = 0;
        
        // 添加每一页的视图并设置frame
        for (NSInteger i = 0; i < pages.count; i++) {
            UIView *pageView = pages[i];
            pageView.frame = CGRectMake(i * frame.size.width, kRefreshControlHeight+30, frame.size.width, frame.size.height-kRefreshControlHeight-70);
            // 添加刷新条
            UIView * refreshControls = [[UIView alloc] initWithFrame:CGRectMake(i * frame.size.width, 0, frame.size.width, kRefreshControlHeight)];
            refreshControls.userInteractionEnabled = NO;
            refreshControls.backgroundColor = [UIColor whiteColor];
            UILabel *label = [[UILabel alloc] initWithFrame:refreshControls.bounds];
            label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y + 60, label.frame.size.width, label.frame.size.height-30);
            label.textAlignment = NSTextAlignmentCenter;
            label.text = @"下拉刷新";
            [self.refreshControllLabels addObject:label];
            [refreshControls addSubview:self.refreshControllLabels[i]];

            [self.refreshControlls addObject:refreshControls];
            // 添加加载更多条
            UIView *loadMoreView = [[UIView alloc] initWithFrame:CGRectMake(i * frame.size.width, frame.size.height - 40, frame.size.width, 80)];
            loadMoreView.backgroundColor = [UIColor whiteColor];
            UILabel *loadMoreLabel = [[UILabel alloc] initWithFrame:loadMoreView.bounds];
            loadMoreLabel.textAlignment = NSTextAlignmentCenter;
            loadMoreLabel.text = @"加载更多";
            loadMoreLabel.textColor = [UIColor orangeColor];
            [loadMoreView addSubview:loadMoreLabel];
            
            [self addSubview:refreshControls];
            [self addSubview:pageView];
            [self addSubview:loadMoreView];
            
        }
        
        // 设置contentSize为所有页面宽度的总和，高度等于scrollView高度
        self.contentSize = CGSizeMake(frame.size.width * pages.count, frame.size.height);
        
        // 添加下拉刷新控件
        
        
        
//        self.refreshControlyes = [[UIView alloc] initWithFrame:CGRectMake(0, -kRefreshControlHeight, frame.size.width, kRefreshControlHeight)];
//        self.refreshControlyes.backgroundColor = [UIColor whiteColor];
//        UILabel *label = [[UILabel alloc] initWithFrame:self.refreshControlyes.bounds];
//        label.textAlignment = NSTextAlignmentCenter;
//        label.text = @"下拉刷新";
//        [self.refreshControlyes addSubview:label];
//        [self addSubview: self.refreshControlyes];
        
        // 添加上滑添加更多控件
//        self.loadMoreControlyes = [[UIView alloc] initWithFrame:CGRectMake(0, self.contentSize.height, self.bounds.size.width, kLoadMoreControlHeight)];
//        self.loadMoreControlyes.backgroundColor = [UIColor clearColor];
        
//        [self layoutSubviews];
//        [self addSubview:self.loadMoreControlyes];
        

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

    if (fabs(deltaX) > fabs(deltaY)) {
        // Horizontal scrolling
        scrollView.contentOffset = CGPointMake(currentContentOffset.x, self.beginContentOffset.y);
    } else {
        // Vertical scrolling
        scrollView.contentOffset = CGPointMake(self.beginContentOffset.x, currentContentOffset.y);
    }
    
    if (scrollView.contentOffset.x < 0 || scrollView.contentOffset.x > scrollView.contentSize.width - scrollView.bounds.size.width) {
        // 禁止左右滑动
        CGPoint offset = scrollView.contentOffset;
        if (scrollView.contentOffset.x < 0) {
            offset.x = 0;
        } else {
            offset.x = scrollView.contentSize.width - scrollView.bounds.size.width;
        }
        scrollView.contentOffset = offset;
    }
    
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
    
    // 判断是否滑动到边界，禁止继续滑动
    if (scrollView.contentOffset.x <= 0 || scrollView.contentOffset.x >= scrollView.contentSize.width - scrollView.frame.size.width) {
        scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y);
    }
    
    
    if (scrollView.contentOffset.y <= -kRefreshControlHeight / 2 - 20  && self.shouldAllowRefresh && !self.isRefreshing) {
        (self.refreshControllLabels[self.currentPage]).text = @"松开刷新";
    } else if (scrollView.contentOffset.y > -kRefreshControlHeight / 2 - 20  && self.shouldAllowRefresh && !self.isRefreshing){
        (self.refreshControllLabels[self.currentPage]).text = @"下拉刷新";
    }
//    // 判断是否滑到了底部
//    CGFloat offsetY = scrollView.contentOffset.y;
//    CGFloat contentHeight = scrollView.contentSize.height;
//    CGFloat scrollViewHeight = scrollView.bounds.size.height;
//    if (offsetY > contentHeight - scrollViewHeight) {
//        // 如果没有正在加载更多，则执行加载更多
//        if (!self.isLoadingMore) {
//            [self startLoadingMore];
//        }
//    }
    NSLog(@"%lf",scrollView.contentOffset.y);
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat pageWidth = scrollView.frame.size.width;
    self.currentPage = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    if(!self.isRefreshing){
        
        // 根据scrollView的contentOffset计算当前页面

        // 使用setContentOffset:animated:方法迅速移动到最近的页面
        [self setContentOffset:CGPointMake(self.currentPage * pageWidth, 0) animated:YES];
    }

    // 发送一次页面消息
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
    // 记录scrollView的拖拽状态
    self.isDragging = YES;
    self.pagingEnabled = YES;
    
    // 记录scrollView的滚动方向
    CGPoint velocity = [scrollView.panGestureRecognizer velocityInView:self];
    self.beginContentOffset = scrollView.contentOffset;
    if (fabs(velocity.x) > fabs(velocity.y)) {
        // 左右滑动，禁止下拉刷新和上滑添加
        self.shouldAllowRefresh = NO;
        self.pagingEnabled = YES;
//        self.shouldAllowLoadMore = NO;
    } else {
        // 上下滑动，允许下拉刷新和上滑添加
//        self.shouldAllowLoadMore = YES;
        self.shouldAllowRefresh = YES;
    }
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    self.isDragging = NO;
    
    // 如果下拉刷新控件已经显示，触发刷新
    if (scrollView.contentOffset.y <= -kRefreshControlHeight / 2 - 20  && self.shouldAllowRefresh) { //
        self.pagingEnabled = NO;
        [self startRefreshing];

    }
    CGFloat pageWidth = scrollView.frame.size.width;
    if(!self.isRefreshing && ((scrollView.contentOffset.x - pageWidth * self.currentPage) / pageWidth )== 0){
        CGFloat pageWidth = self.frame.size.width;
        // 根据scrollView的contentOffset计算当前页面
        self.currentPage = floor((self.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        // 使用setContentOffset:animated:方法迅速移动到最近的页面
        [self setContentOffset:CGPointMake(self.currentPage * pageWidth, 0) animated:YES];
    }
    
    // 如果滑到了底部，触发加载更多
        if (scrollView.contentOffset.y + scrollView.frame.size.height >= scrollView.contentSize.height + 80) {
            [UIView animateWithDuration:0.5 animations:^{
                UIEdgeInsets insets = scrollView.contentInset;
                scrollView.contentInset = insets;
            } completion:^(BOOL finished) {
                if (self.loadMoreBlock) {
                    self.loadMoreBlock();
                }
            }];
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
    (self.refreshControllLabels[self.currentPage]).text = @"正在刷新";
    if (self.isDragging) {
        return;
    }
    self.isRefreshing = YES;
    [self setContentOffset:CGPointMake(self.contentOffset.x, -kRefreshControlHeight) animated:YES];
    if (self.refreshBlock) {
        self.refreshBlock();
    }
//    [UIView animateWithDuration:0.5 animations:^{
////        UIEdgeInsets insets = self.contentInset;
////        insets.top += kRefreshControlHeight;
////        self.contentInset = insets;
//
//        self.contentOffset = CGPointMake(self.contentOffset.x, -kRefreshControlHeight);
//
//    } completion:^(BOOL finished) {
//        if (self.refreshBlock) {
//            self.refreshBlock();
//        }
//    }];
}

- (void)endRefreshing {
    CGFloat pageWidth = self.frame.size.width;
    // 根据scrollView的contentOffset计算当前页面
    self.currentPage = floor((self.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    // 使用setContentOffset:animated:方法迅速移动到最近的页面
    if (self.isRefreshing) {
    [self setContentOffset:CGPointMake(self.currentPage * pageWidth, 0) animated:YES];
    self.isRefreshing = NO;
    }
    
}

//- (void)startLoadingMore {
//    if (self.isDragging) {
//            return;
//        }
//        self.isLoadingMore = YES;
//        CGFloat contentHeight = self.contentSize.height;
//        CGFloat height = CGRectGetHeight(self.frame);
//        CGFloat offsetY = self.contentOffset.y;
//        CGFloat maxOffsetY = contentHeight - height;
//        if (offsetY < maxOffsetY) {
//            // 如果当前页面没有滑到底部，则滑动到底部
//            [UIView animateWithDuration:0.3 animations:^{
//                UIEdgeInsets insets = self.contentInset;
//                insets.bottom += kLoadMoreControlHeight;
//                self.contentInset = insets;
//            } completion:^(BOOL finished) {
//                if (self.loadMoreBlock) {
//                        self.loadMoreBlock();
//                    }
//            }];
//        } else {
//            // 如果当前页面已经滑到底部，则直接加载更多数据
//            if (self.loadMoreBlock) {
//                    self.loadMoreBlock();
//            }
//        }
//}
//
//- (void)endLoadingMore {
//    if (self.isLoadingMore) {
//        UILabel *label = [[UILabel alloc] initWithFrame:self.loadMoreControlyes.bounds];
//        label.text = @"正在加载更多";
//        label.textColor = [UIColor grayColor];
//        label.textAlignment = NSTextAlignmentCenter;
//        [self.loadMoreControlyes addSubview:label];
//        [UIView animateWithDuration:0.3 animations:^{
//            UIEdgeInsets insets = self.contentInset;
//            insets.bottom -= kLoadMoreControlHeight;
//            self.contentInset = insets;
//        } completion:^(BOOL finished) {
//            self.isLoadingMore = NO;
//        }];
//    }
//}
//
//- (void)layoutSubviews {
//    [super layoutSubviews];
//
//    CGFloat width = self.bounds.size.width;
//    CGFloat height = self.bounds.size.height;
//
//    // 调整pagingScrollView的尺寸和位置
//    self.frame = CGRectMake(0, 0, width, height);
//
//    // 调整refreshControl的位置
//    if (self.refreshControl) {
//        CGRect refreshControlFrame = self.refreshControl.frame;
//        refreshControlFrame.origin.y = -kRefreshControlHeight;
//        refreshControlFrame.size.width = width;
//        self.refreshControl.frame = refreshControlFrame;
//    }
//
//    // 调整loadMoreControl的位置
//    if (self.loadMoreControlyes) {
//        CGRect loadMoreControlFrame = self.loadMoreControlyes.frame;
//        loadMoreControlFrame.origin.y = self.contentSize.height;
//        loadMoreControlFrame.size.width = width;
//        self.loadMoreControlyes.frame = loadMoreControlFrame;
//    }
//
//    // 计算contentSize
//    CGSize contentSize = CGSizeMake(width, height);
//    if (self.pages.count > 0) {
//        UIView *lastPage = [self.pages lastObject];
////        contentSize.height += CGRectGetMaxY(lastPage.frame);
//    }
//    if (self.refreshControl) {
//        contentSize.height += kRefreshControlHeight;
//    }
//    if (self.loadMoreControlyes) {
//        contentSize.height += kLoadMoreControlHeight*2;
//    }
//    self.contentSize = contentSize;
//}

@end

