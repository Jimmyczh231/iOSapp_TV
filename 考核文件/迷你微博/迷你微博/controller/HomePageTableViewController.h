//
//  HomePageTableViewController.h
//  迷你微博
//
//  Created by jimmy on 5/12/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN



@protocol HomePageTableViewControllerDelegate <NSObject>

@required
// 显示详情页的方法
- (void)presentWeiboDetailWith:(NSDictionary*)status;

@end

@interface HomePageTableViewController : UITableViewController

@property (nonatomic, readwrite) BOOL needToRefresh;
@property (nonatomic, readwrite) BOOL canLoadMoreData;
@property (nonatomic, weak) id<HomePageTableViewControllerDelegate> delegate;

- (void)loadMoreDataOnTableViewWithCompletion:(void (^)(BOOL))completion;
- (void)refreshTableViewWithCompletion:(void (^)(BOOL))completion;
- (void)autorefresh;
@end

NS_ASSUME_NONNULL_END
