//
//  HomePageTableViewController.m
//  迷你微博
//
//  Created by jimmy on 5/12/23.
//

#import "HomePageTableViewController.h"
#import "HomePageTableViewCell.h"
#import "WeiboHomePageManager.h"
#import "AccessToken.h"
#import "WeiboWebViewController.h"
#import "MJRefresh.h"

@interface HomePageTableViewController ()<UITableViewDelegate, UITableViewDataSource>


@property (nonatomic, strong, readwrite) NSMutableArray *DataArray;
@property (nonatomic, strong, readwrite) WeiboWebViewController *webViewController;
@property (nonatomic, strong, readwrite) WeiboHomePageManager *manager;
@property (nonatomic, strong, readwrite) NSTimer *refreshTimer;
@property (nonatomic, readwrite) BOOL timeToRefresh;



@end

@implementation HomePageTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.needToRefresh = YES;
    self.canLoadMoreData = YES;
    self.manager = [[WeiboHomePageManager alloc] initWithAccessToken:[AccessToken sharedInstance].accessToken];
    // 加载数据
//    [self.manager refreshHomePageDataWithCompletion:^(BOOL success, NSArray *weiboDataArray) {
//        if (success) {
//            // 加载成功，更新界面
//            dispatch_async(dispatch_get_main_queue(), ^{
//                self.DataArray = [weiboDataArray mutableCopy];;
//                [self.tableView reloadData];
//            });
//
//        } else {
//            self.needToRefresh = YES;
//        }
//    }];
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(mjRefreshTableView)];
    [header setTitle:@"下拉刷新" forState:MJRefreshStateIdle];
    [header setTitle:@"释放以刷新" forState:MJRefreshStatePulling];
    [header setTitle:@"正在刷新..." forState:MJRefreshStateRefreshing];
    [header setTitle:@"刷新完成" forState:MJRefreshStateNoMoreData];
    header.ignoredScrollViewContentInsetTop = 30;
    self.tableView.mj_header = header;

    [self.tableView.mj_header beginRefreshing];
    self.timeToRefresh = YES;
    
    // 设置 Timer 计时刷新
    self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:300.0 target:self selector:@selector(timeToRefresh:) userInfo:nil repeats:YES];
    
    [self.tableView reloadData];
}

 // 自动刷新
- (void)autorefresh {
    if(self.timeToRefresh){
        [self mjRefreshTableView];
        self.timeToRefresh = NO;
    }
}

- (void)timeToRefresh:(NSTimer *)timer {
    self.needToRefresh = YES;
    self.timeToRefresh = YES;
}

#pragma mark - 数据刷新和加载
// 刷新数据
- (void)refreshTableViewWithCompletion:(void (^)(BOOL))completion{
    // 如果允许刷新数据，刷新数据
    if(self.needToRefresh){
        self.canLoadMoreData = NO;
        __weak typeof(self) weakSelf = self;
        [self.manager refreshHomePageDataWithCompletion:^(BOOL success, NSArray *weiboDataArray) {
            __strong typeof (self) strongself = weakSelf;
            if (success) {
                // 加载成功，更新界面
                dispatch_async(dispatch_get_main_queue(), ^{
                    strongself.DataArray = [weiboDataArray mutableCopy];;
                    [strongself.tableView reloadData];
                    strongself.needToRefresh = NO;
                    self.canLoadMoreData = YES;
                    completion(YES);
                });
            } else {
                strongself.needToRefresh = YES;
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(NO);
                });
            }
        }];
    }
    self.needToRefresh = NO;
}

// 加载更多
- (void)loadMoreDataOnTableViewWithCompletion:(void (^)(BOOL))completion{
    if(self.canLoadMoreData){
        self.canLoadMoreData = NO;
        __weak typeof(self) weakSelf = self;
        [self.manager loadMoreHomePageDataWithCompletion:^(BOOL success, NSArray *weiboDataArray) {
            __strong typeof (self) strongself = weakSelf;
            if (success || weiboDataArray != nil) {
                // 加载成功，更新界面
                dispatch_async(dispatch_get_main_queue(), ^{
                    [strongself.DataArray addObjectsFromArray:weiboDataArray];
                    [strongself.tableView reloadData];
                    strongself.canLoadMoreData = YES;
                    completion(YES);
                });
                
            } else {
                // 加载失败，处理错误
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"加载失败" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
                    [alert addAction:okAction];
                    [strongself presentViewController:alert animated:YES completion:nil];
                    completion(NO);
                    strongself.canLoadMoreData = YES;
                });
            }
        }];
        
    }
        

}

// 刷新数据2
- (void)mjRefreshTableView{
    // 如果允许刷新数据，刷新数据
    if(self.needToRefresh){
        self.needToRefresh = NO;
        self.canLoadMoreData = NO;
        __weak typeof(self) weakSelf = self;
        [self.manager refreshHomePageDataWithCompletion:^(BOOL success, NSArray *weiboDataArray) {
            __strong typeof (self) strongself = weakSelf;
            if (success) {
                // 加载成功，更新界面
                dispatch_async(dispatch_get_main_queue(), ^{
                    strongself.DataArray = [weiboDataArray mutableCopy];;
                    [strongself.tableView reloadData];
                    
                    self.canLoadMoreData = YES;
                });
                strongself.needToRefresh = YES;
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{

                });
                strongself.needToRefresh = YES;
            }
            [strongself.tableView.mj_header endRefreshing];
        }];
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return self.DataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"MyCell";
    NSDictionary *status = self.DataArray[indexPath.row];
    HomePageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[HomePageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier andwith:[status objectForKey:@"text"] andwith:[[status objectForKey:@"user"] objectForKey:@"name"] andwith:[self getAllThumbnailUrlsFromArray:[status objectForKey:@"pic_urls"]]];
    }

//    cell.textContentLabel.text = [status objectForKey:@"text"];
//    cell.nameLabel.text = [[status objectForKey:@"user"] objectForKey:@"name"];
//    cell.imagesUrl = [self getAllThumbnailUrlsFromArray:[status objectForKey:@"pic_urls"]];
    
    // 设置cell的内容
    NSNumber *picNum = [status objectForKey:@"pic_num"];
    cell.imageNumber = picNum.intValue;
    cell.status = status;
    [cell layoutSubViewWith:[status objectForKey:@"text"] andWith:[[status objectForKey:@"user"] objectForKey:@"name"] andWith:[self getAllThumbnailUrlsFromArray:[status objectForKey:@"pic_urls"]] andWith:[NSURL URLWithString:[[status objectForKey:@"user"] objectForKey:@"profile_image_url"]]];
    return cell;
}

// 获取图片 URL
- (NSMutableArray *)getAllThumbnailUrlsFromArray:(NSArray *)array {
    NSMutableArray *thumbnailUrls = [NSMutableArray array];
    for (NSDictionary *dict in array) {
            NSURL *thumbnailUrl = [NSURL URLWithString:[dict objectForKey:@"thumbnail_pic"]];
            [thumbnailUrls addObject:thumbnailUrl];
    }
    return thumbnailUrls;
}

// 根据数据计算cell高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableDictionary *status = self.DataArray[indexPath.row];
    CGFloat height = 50.0;
    height += [self heightForText:[status objectForKey:@"text"]];
    NSMutableArray *picUrlArray = [status objectForKey:@"pic_urls"];
    int picNumber = picUrlArray.count;
    if (picNumber == 0) {
        height += 20;
    }else if (picNumber == 1){
        height += (10.0 + (CGRectGetWidth([UIScreen mainScreen].bounds) - 40.0) / 3) * 1.5;
    }else if (picNumber <= 3) {
        height += (10.0 + (CGRectGetWidth([UIScreen mainScreen].bounds) - 40.0) / 3) * ((picNumber - 1) / 2 + 1);
    } else if (picNumber<= 6) {
        height += (10.0 + (CGRectGetWidth([UIScreen mainScreen].bounds) - 40.0) / 3) * 2;
    } else {
        NSNumber *picNum = [status objectForKey:@"pic_num"];
        picNumber = picNum.intValue;
        height += (10.0 + (CGRectGetWidth([UIScreen mainScreen].bounds) - 40.0) / 3) * 3;
    }
    height += 65.0;
    return height;
}

- (CGFloat)heightForText:(NSString *)text {
    CGFloat screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    CGFloat margin = 10.0;
    CGFloat labelWidth = screenWidth - margin * 2;
    CGFloat minHeight = 20.0;
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:14.0];
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByTruncatingTail;
    label.text = text;
    CGSize size = [label sizeThatFits:CGSizeMake(labelWidth, CGFLOAT_MAX)];
    return MAX(size.height, minHeight);
}
    
#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableDictionary *status = self.DataArray[indexPath.row];
    
    // 发送添加到历史记录通知
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AddHistoryData" object:nil userInfo:status];

    if(self.delegate != nil){
        [self.delegate presentWeiboDetailWith:status];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}
/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
