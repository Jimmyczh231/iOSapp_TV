//
//  HomePageTableViewController.h
//  迷你微博
//
//  Created by jimmy on 5/12/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HomePageTableViewController : UITableViewController

@property (nonatomic, readwrite) BOOL needToRefresh;
@property (nonatomic, readwrite) BOOL canLoadMoreData;

- (void)refreshTableView;
- (void)loadMoreDataOnTableView;

@end

NS_ASSUME_NONNULL_END
