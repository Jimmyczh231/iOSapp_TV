//
//  CostomScrollView.h
//  迷你微博
//
//  Created by jimmy on 5/10/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CostomScrollView : UIScrollView

typedef void (^MyPagingScrollViewDidSelectPageBlock)(NSInteger page);
typedef void (^MyPagingScrollViewRefreshBlock)(void);
typedef void (^MyPagingScrollViewLoadMoreBlock)(void);

@property (nonatomic, strong) UIView *refreshControlyes;
@property (nonatomic, strong) UIView *loadMoreControlyes;
@property (nonatomic, assign) NSInteger numberOfPages;
@property (nonatomic, strong) NSArray *pages;
@property (nonatomic, assign) NSInteger currentPage;

@property (nonatomic, copy) void (^didScrollToPageBlock)(NSInteger currentPage, CGFloat progress);
@property (nonatomic, copy) MyPagingScrollViewDidSelectPageBlock didSelectPageBlock;
@property (nonatomic, copy) MyPagingScrollViewRefreshBlock refreshBlock;
@property (nonatomic, copy) MyPagingScrollViewLoadMoreBlock loadMoreBlock;

- (instancetype)initWithFrame:(CGRect)frame pages:(NSArray *)pages;
- (void)startRefreshing;
- (void)endRefreshing;
- (void)startLoadingMore;
- (void)endLoadingMore;

@end

NS_ASSUME_NONNULL_END
