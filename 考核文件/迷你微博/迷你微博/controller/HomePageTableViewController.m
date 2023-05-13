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


@interface HomePageTableViewController ()<UITableViewDelegate, UITableViewDataSource>


@property (nonatomic, strong, readwrite) NSMutableArray *DataArray;
@property (nonatomic, strong, readwrite) WeiboWebViewController *webViewController;

@end

@implementation HomePageTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    WeiboHomePageManager *manager = [[WeiboHomePageManager alloc] initWithAccessToken:[AccessToken sharedInstance].accessToken];
    [manager refreshHomePageDataWithCompletion:^(BOOL success, NSArray *weiboDataArray) {
        if (success) {
            // 加载成功，更新界面
            dispatch_async(dispatch_get_main_queue(), ^{
                self.DataArray = [weiboDataArray mutableCopy];;
                [self.tableView reloadData];
            });

        } else {
            // 加载失败，处理错误
        }
    }];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOpenURLNotification:) name:@"OpenURLNotification" object:nil];

    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.tableView reloadData];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"OpenURLNotification" object:nil];
}

- (void)handleOpenURLNotification:(NSNotification *)notification {
    NSURL *url = notification.userInfo[@"url"];
    self.webViewController = [[WeiboWebViewController alloc]initWithURL:url];
    [self.navigationController pushViewController:self.webViewController animated:YES];

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

    NSNumber *picNum = [status objectForKey:@"pic_num"];
    cell.imageNumber = picNum.intValue;
    cell.textContentLabel.text = [status objectForKey:@"text"];
    cell.nameLabel.text = [[status objectForKey:@"user"] objectForKey:@"name"];
    cell.imagesUrl = [self getAllThumbnailUrlsFromArray:[status objectForKey:@"pic_urls"]];
    [cell layoutSubviewwith:[status objectForKey:@"text"] andwith:[[status objectForKey:@"user"] objectForKey:@"name"] andwith:cell.imagesUrl andwith:[NSURL URLWithString:[[status objectForKey:@"user"] objectForKey:@"profile_image_url"]]];
    return cell;
}

- (NSMutableArray *)getAllThumbnailUrlsFromArray:(NSArray *)array {
    NSMutableArray *thumbnailUrls = [NSMutableArray array];
    for (NSDictionary *dict in array) {
        // 判断字典中是否包含 key 为 "thumbnail_pic" 的值
//        if ([dict objectForKey:@"thumbnail_pic"]) {
            // 获取 key 为 "thumbnail_pic" 的 NSURL 对象
            NSURL *thumbnailUrl = [NSURL URLWithString:[dict objectForKey:@"thumbnail_pic"]];
            [thumbnailUrls addObject:thumbnailUrl];
//        }
    }
    return thumbnailUrls;
}

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
    height += 45.0;
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
