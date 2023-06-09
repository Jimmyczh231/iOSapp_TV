//
//  rootViewController.m
//  迷你微博
//
//  Created by jimmy on 5/9/23.
//

#import "rootViewController.h"
#import "ScrollableWithTitleViewController.h"
#import "testviewcontroller.h"
#import "HomePageTableViewController.h"
#import "MyWeiboViewController.h"

/*
这个是底层的 viewcontroller 主要是初始化 tabbar
 */

@interface rootViewController ()

@end
 
@implementation rootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.rootTabbar = [[UITabBarController alloc] init];
    
    ScrollableWithTitleViewController *viewController1 = [[ScrollableWithTitleViewController alloc] init];
    testviewcontroller *viewController4 = [[testviewcontroller alloc] init];
    HomePageTableViewController *viewController2 = [[HomePageTableViewController alloc] init];
    MyWeiboViewController *viewController5 = [[MyWeiboViewController alloc] init];

    // 创建 ViewController1

    viewController1.tabBarItem.title = @"首页";
    viewController1.tabBarItem.image = [UIImage imageNamed:@"shouye.png"];

    // 创建 ViewController2

    viewController2.tabBarItem.title = @"图标2";
    viewController2.tabBarItem.image = [UIImage imageNamed:@"图标2"];

    // 创建 ViewController3
    UIViewController *viewController3 = [[UIViewController alloc] init];
    viewController3.tabBarItem.title = @"图标3";
    viewController3.tabBarItem.image = [UIImage imageNamed:@"图标3"];
    

    // 创建 ViewController4

    viewController4.tabBarItem.title = @"图标4";
    viewController4.tabBarItem.image = [UIImage imageNamed:@"图标4"];

    // 创建 ViewController5
    viewController5.tabBarItem.title = @"我";
    viewController5.tabBarItem.image = [UIImage imageNamed:@"wo.png"];

    // 将 ViewController1 到 ViewController5 添加到 TabBarController 中
    self.rootTabbar.viewControllers = @[viewController1, viewController2, viewController3, viewController4, viewController5];

    [self.navigationController addChildViewController:self.rootTabbar];
    
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
