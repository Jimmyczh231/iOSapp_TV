//
//  ShoucangTableViewController.m
//  迷你微博
//
//  Created by jimmy on 5/17/23.
//

#import "ShoucangTableViewController.h"
#import "ShoucangManager.h"
#import "HomePageTableViewCell.h"

/*
 这个页面和homepage几乎一样
 */

@interface ShoucangTableViewController ()

@property (nonatomic, strong, readwrite) NSArray *DataArray;
@property (nonatomic, strong, readwrite) ShoucangManager *manager;

@end

@implementation ShoucangTableViewController

- (instancetype)init{
    self = [super init];
    if (self) {
        self.manager = [ShoucangManager sharedManager];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"收藏";
    [self refreshShoucangTableView];


}

- (void)viewWillAppear:(BOOL)animated{
    NSLog(@"HistoryViewAppeared");
    [self refreshShoucangTableView];
    
}

- (void)refreshShoucangTableView{
    [self.manager loadShoucangDataWithCompletion:^(NSArray *shoucangDataArray) {
        self.DataArray = shoucangDataArray;
        
        [self.tableView reloadData];
    }];
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
    static NSString *cellIdentifier = @"ShoucangCell";
    NSDictionary *status = self.DataArray[indexPath.row];
    HomePageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[HomePageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier andwith:[status objectForKey:@"text"] andwith:[[status objectForKey:@"user"] objectForKey:@"name"] andwith:[self getAllThumbnailUrlsFromArray:[status objectForKey:@"pic_urls"]]];
    }


//    cell.textContentLabel.text = [status objectForKey:@"text"];
//    cell.nameLabel.text = [[status objectForKey:@"user"] objectForKey:@"name"];
//    cell.imagesUrl = [self getAllThumbnailUrlsFromArray:[status objectForKey:@"pic_urls"]];
    NSNumber *picNum = [status objectForKey:@"pic_num"];
    cell.imageNumber = picNum.intValue;
    cell.status = status;
    [cell layoutSubViewWith:[status objectForKey:@"text"] andWith:[[status objectForKey:@"user"] objectForKey:@"name"] andWith:cell.imagesUrl andWith:[NSURL URLWithString:[[status objectForKey:@"user"] objectForKey:@"profile_image_url"]]];
    return cell;
}

- (NSMutableArray *)getAllThumbnailUrlsFromArray:(NSArray *)array {
    NSMutableArray *thumbnailUrls = [NSMutableArray array];
    for (NSDictionary *dict in array) {
            NSURL *thumbnailUrl = [NSURL URLWithString:[dict objectForKey:@"thumbnail_pic"]];
            [thumbnailUrls addObject:thumbnailUrl];
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
    NSLog(@"shoucangdianji");
//    if(self.delegate != nil){
//        [self.delegate presentWeiboDetailWith:status];
//    }
    // 发送添加到历史记录通知
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AddHistoryData" object:nil userInfo:status];
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
