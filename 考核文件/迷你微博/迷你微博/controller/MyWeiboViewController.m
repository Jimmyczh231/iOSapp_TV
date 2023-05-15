//
//  MyWeiboViewController.m
//  迷你微博
//
//  Created by jimmy on 5/15/23.
//

#import "MyWeiboViewController.h"
#import "MyWeiboViewManager.h"

@interface MyWeiboViewController ()
@property (nonatomic, strong) MyWeiboViewManager *manager;
@property (nonatomic, strong) NSDictionary *MyViewDataDictionary;
@property (nonatomic, readwrite) BOOL needToRefresh;
@end

@implementation MyWeiboViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.manager  = [[MyWeiboViewManager alloc]init];
    __weak typeof(self) weakSelf = self;
    [self.manager refreshMyWeiboPageDataWithCompletion:^(BOOL success, NSDictionary *weiboDataArray) {
        __strong typeof (self) strongself = weakSelf;
        if (success) {
            // 加载成功，更新界面
            dispatch_async(dispatch_get_main_queue(), ^{
                strongself.MyViewDataDictionary = [weiboDataArray mutableCopy];;

                strongself.needToRefresh = NO;
            });
            
        } else {
            // 加载失败，处理错误
            strongself.needToRefresh = YES;
        }
    }];
    
    
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
