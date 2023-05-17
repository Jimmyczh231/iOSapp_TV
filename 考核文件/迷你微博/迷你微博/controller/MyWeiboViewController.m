//
//  MyWeiboViewController.m
//  迷你微博
//
//  Created by jimmy on 5/15/23.
//

#import "MyWeiboViewController.h"
#import "MyWeiboViewManager.h"
#import "ImageLoader.h"

@interface MyWeiboViewController ()
@property (nonatomic, strong) MyWeiboViewManager *manager;
@property (nonatomic, strong) NSDictionary *MyViewDataDictionary;
@property (nonatomic, readwrite) BOOL needToRefresh;

@property (nonatomic, strong) UIImageView *userProfileImageView;
@property (nonatomic, strong) UIView *buttonView;
@property (nonatomic, strong) UILabel *weiboLable;
@property (nonatomic, strong) UILabel *followLable;
@property (nonatomic, strong) UILabel *fansLable;
@property (nonatomic, strong) UILabel *weiboNumberLable;
@property (nonatomic, strong) UILabel *followNumberLable;
@property (nonatomic, strong) UILabel *fansNumberLable;
@property (nonatomic, strong) UILabel *usernameLabel;
@property (nonatomic, strong) UILabel *followersLabel;
@property (nonatomic, strong) UILabel *followingLabel;

@end

@implementation MyWeiboViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.view.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1];;
    self.manager  = [[MyWeiboViewManager alloc]init];
    __weak typeof(self) weakSelf = self;
    [self layOutAllView];
    [self.manager refreshMyWeiboPageDataWithCompletion:^(BOOL success, NSDictionary *weiboDataArray) {
        __strong typeof (self) strongself = weakSelf;
        if (success) {
            // 加载成功，更新界面
            dispatch_async(dispatch_get_main_queue(), ^{
                strongself.MyViewDataDictionary = [weiboDataArray mutableCopy];;
                self.fansNumberLable.text = [weiboDataArray objectForKey:@"followers_count_str"];
                self.followNumberLable.text = [[weiboDataArray objectForKey:@"friends_count"] stringValue];
                self.weiboNumberLable.text = [[weiboDataArray objectForKey:@"statuses_count"] stringValue];
                self.usernameLabel.text = [weiboDataArray objectForKey:@"screen_name"];
                NSURL* url = [NSURL URLWithString:[weiboDataArray objectForKey:@"profile_image_url"]];
                [[ImageLoader sharedInstance] loadImageWithURL:url completion:^(UIImage * _Nonnull image) {
                    if (image) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.userProfileImageView.image = image;
                        });
                    } else {
                        NSLog(@"Failed to load image");
                    }
                }];
                
                strongself.needToRefresh = NO;
            });
            
        } else {
            // 加载失败，处理错误
            strongself.needToRefresh = YES;
        }
    }];
    
    
    
}

- (void)layOutAllView{
    //用户头像初始化
//    self.profileImageUrl = profileImageUrl;
    self.userProfileImageView = [[UIImageView alloc] init];
    self.userProfileImageView.image = [UIImage imageNamed:@"loading-icon.jpg"];
#warning 图片通过URL加载还没写

    self.userProfileImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.userProfileImageView.layer.cornerRadius = 30.0;
    self.userProfileImageView.layer.masksToBounds = YES;
    NSLayoutConstraint *profileImageLeft = [NSLayoutConstraint constraintWithItem:self.userProfileImageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:30];
    NSLayoutConstraint *profileImageTop = [NSLayoutConstraint constraintWithItem:self.userProfileImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:100];
    NSLayoutConstraint *profileImagewidth = [NSLayoutConstraint constraintWithItem:self.userProfileImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:60];
    NSLayoutConstraint *profileImageheight = [NSLayoutConstraint constraintWithItem:self.userProfileImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:60];
    [self.view addSubview:self.userProfileImageView];
    [self.view addConstraints:@[profileImageLeft, profileImageTop]];
    [ self.userProfileImageView addConstraints:@[profileImagewidth, profileImageheight]];
    
    //用户名初始化
    self.usernameLabel = [[UILabel alloc] init];
#warning 图片通过URL加载还没写
    self.usernameLabel.text = @"name";
    self.usernameLabel.font = [UIFont boldSystemFontOfSize:20.0];
    [self.view addSubview:self.usernameLabel];
    [self.usernameLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSLayoutConstraint *nameLabelLeft = [NSLayoutConstraint constraintWithItem:self.usernameLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.userProfileImageView attribute:NSLayoutAttributeRight multiplier:1 constant:15];
    NSLayoutConstraint *nameLabelTop = [NSLayoutConstraint constraintWithItem:self.usernameLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:100];
    [self.view addConstraints:@[nameLabelLeft, nameLabelTop]];
    
#warning 还没写数字label
    self.weiboNumberLable = [self createLabelWithText:@"0" frame:CGRectMake(0, 230, (self.view.frame.size.width) / 3, 25) font:[UIFont boldSystemFontOfSize:25.0] textcoler:[UIColor blackColor]];
    self.followNumberLable = [self createLabelWithText:@"0" frame:CGRectMake((self.view.frame.size.width) / 3, 230, (self.view.frame.size.width) / 3, 25) font:[UIFont boldSystemFontOfSize:25.0] textcoler:[UIColor blackColor]];
    self.fansNumberLable = [self createLabelWithText:@"0" frame:CGRectMake( (self.view.frame.size.width) * 2 / 3, 230, (self.view.frame.size.width) / 3, 25) font:[UIFont boldSystemFontOfSize:25.0] textcoler:[UIColor blackColor]];
    
    self.weiboLable = [self createLabelWithText:@"微博" frame:CGRectMake(0, 260, (self.view.frame.size.width) / 3, 15) font:[UIFont systemFontOfSize:15.0] textcoler:[UIColor lightGrayColor]];
    self.followLable = [self createLabelWithText:@"关注" frame:CGRectMake((self.view.frame.size.width) / 3, 260, (self.view.frame.size.width) / 3, 15) font:[UIFont systemFontOfSize:15.0] textcoler:[UIColor lightGrayColor]];
    self.fansLable = [self createLabelWithText:@"粉丝" frame:CGRectMake( (self.view.frame.size.width) * 2 / 3, 260, (self.view.frame.size.width) / 3, 15) font:[UIFont systemFontOfSize:15.0] textcoler:[UIColor lightGrayColor]];
    [self.view addSubview:self.weiboNumberLable];
    [self.view addSubview:self.followNumberLable];
    [self.view addSubview:self.fansNumberLable];
    [self.view addSubview:self.weiboLable];
    [self.view addSubview:self.followLable];
    [self.view addSubview:self.fansLable];
    
    
    // 按键部分初始化
    self.buttonView = [[UIView alloc]initWithFrame:CGRectMake(15, 300, [UIScreen mainScreen].bounds.size.width-30, 150)];
    self.buttonView.backgroundColor = [UIColor whiteColor];
    self.buttonView.layer.cornerRadius = 5.0;
    self.userProfileImageView.layer.masksToBounds = YES;
    [self.view addSubview:self.buttonView];
    
    UIButton *shoucangButton = [[UIButton alloc]init];
    shoucangButton.frame = CGRectMake(20, 10, (self.buttonView.bounds.size.width-160) / 4, (self.buttonView.bounds.size.width-160) / 4);
    shoucangButton.backgroundColor = [UIColor whiteColor];
    UIImage *shoucang = [UIImage imageNamed:@"shoucang.png"];
    [shoucangButton setImage:shoucang forState:UIControlStateNormal];
    [shoucangButton addTarget:self action:@selector(shoucangButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *histroyButton = [[UIButton alloc]init];
    histroyButton.frame = CGRectMake((self.buttonView.bounds.size.width-160) / 4 + 60, 10, (self.buttonView.bounds.size.width-160)/4, (self.buttonView.bounds.size.width-160)/4);
    histroyButton.backgroundColor = [UIColor whiteColor];
    UIImage *histroyImage = [UIImage imageNamed:@"lishijilu.png"];
    [histroyButton setImage:histroyImage forState:UIControlStateNormal];
    [histroyButton addTarget:self action:@selector(histroyButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *tupianButton = [[UIButton alloc]init];
    tupianButton.frame = CGRectMake((self.buttonView.bounds.size.width-160) * 2 / 4 + 100, 10, (self.buttonView.bounds.size.width-160)/4, (self.buttonView.bounds.size.width-160)/4);
    tupianButton.backgroundColor = [UIColor whiteColor];
    UIImage *tupianImage = [UIImage imageNamed:@"tupian.png"];
    [tupianButton setImage:tupianImage forState:UIControlStateNormal];
    
    UIButton *qianbaoButton = [[UIButton alloc]init];
    qianbaoButton.frame = CGRectMake((self.buttonView.bounds.size.width-160) * 3 / 4 + 140, 10, (self.buttonView.bounds.size.width-160)/4, (self.buttonView.bounds.size.width-160)/4);
    qianbaoButton.backgroundColor = [UIColor whiteColor];
    UIImage *qianbaoImage = [UIImage imageNamed:@"qianbao.png"];
    [qianbaoButton setImage:qianbaoImage forState:UIControlStateNormal];

    [self.buttonView addSubview:shoucangButton];
    [self.buttonView addSubview:histroyButton];
    [self.buttonView addSubview:tupianButton];
    [self.buttonView addSubview:qianbaoButton];
    
}


- (UILabel *)createLabelWithText:(NSString *)text frame:(CGRect)frame font:(UIFont*)font textcoler:(UIColor*)coler{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = font;
    label.text = text;
    label.textColor = coler;
    return label;
}


- (void)shoucangButtonClicked:(UIButton *)sender{
    
}

- (void)histroyButtonClicked:(UIButton *)sender{
    
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
