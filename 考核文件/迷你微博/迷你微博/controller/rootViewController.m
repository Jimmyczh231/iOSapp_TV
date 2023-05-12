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

@interface rootViewController ()

@end
 
@implementation rootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.rootTabbar = [[UITabBarController alloc] init];
    
    ScrollableWithTitleViewController *viewController1 = [[ScrollableWithTitleViewController alloc] init];
    testviewcontroller *viewController4 = [[testviewcontroller alloc] init];
    HomePageTableViewController *viewController2 = [[HomePageTableViewController alloc] init];
    // 创建 ViewController1

    viewController1.tabBarItem.title = @"图标1";
    viewController1.tabBarItem.image = [UIImage imageNamed:@"图标1"];

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
    UIViewController *viewController5 = [[UIViewController alloc] init];
    viewController5.tabBarItem.title = @"图标5";
    viewController5.tabBarItem.image = [UIImage imageNamed:@"图标5"];

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
