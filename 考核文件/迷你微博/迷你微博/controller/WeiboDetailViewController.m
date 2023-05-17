//
//  WeiboDetailViewController.m
//  迷你微博
//
//  Created by jimmy on 5/17/23.
//

#import "WeiboDetailViewController.h"
#import "WeiboDetailViewManager.h"

#warning 我没有写微博为转发微博时的逻辑

@interface WeiboDetailViewController ()

@property (nonatomic, strong) WeiboDetailViewManager *manager;
@property (nonatomic, strong) NSString *weiboId;
@property (nonatomic, strong) NSDictionary *weiboDataDictionary;

@end

@implementation WeiboDetailViewController

- (instancetype)initWithId:(NSString*)weiboId {
    self = [super init];
    if (self) {
        self.weiboId = weiboId;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.manager = [[WeiboDetailViewManager alloc]init];
    [self.manager loadWeiboDetailPageDataWith:self.weiboId andWithCompletion:^(BOOL success, NSDictionary * _Nonnull weiboDataDictionary) {
        self.weiboDataDictionary = weiboDataDictionary;
        
        
        
        
    }];
    // Do any additional setup after loading the view.
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
