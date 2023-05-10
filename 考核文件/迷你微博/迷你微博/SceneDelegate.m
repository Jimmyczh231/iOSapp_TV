//
//  SceneDelegate.m
//  迷你微博
//
//  Created by jimmy on 5/9/23.
//

#import "SceneDelegate.h"
#import "rootViewController.h"
@interface SceneDelegate ()

@property (nonatomic, strong) UITabBarController *rootTabbar;
@end

@implementation SceneDelegate


- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
//    // 创建 TabBarController
//    self.rootTabbar = [[UITabBarController alloc] init];
//
//    // 创建 ViewController1
//    UIViewController *viewController1 = [[UIViewController alloc] init];
//    viewController1.tabBarItem.title = @"图标1";
//    viewController1.tabBarItem.image = [UIImage imageNamed:@"图标1"];
//
//    // 创建 ViewController2
//    UIViewController *viewController2 = [[UIViewController alloc] init];
//    viewController2.tabBarItem.title = @"图标2";
//    viewController2.tabBarItem.image = [UIImage imageNamed:@"图标2"];
//
//    // 创建 ViewController3
//    UIViewController *viewController3 = [[UIViewController alloc] init];
//    viewController3.tabBarItem.title = @"图标3";
//    viewController3.tabBarItem.image = [UIImage imageNamed:@"图标3"];
//
//    // 创建 ViewController4
//    UIViewController *viewController4 = [[UIViewController alloc] init];
//    viewController4.tabBarItem.title = @"图标4";
//    viewController4.tabBarItem.image = [UIImage imageNamed:@"图标4"];
//
//    // 创建 ViewController5
//    UIViewController *viewController5 = [[UIViewController alloc] init];
//    viewController5.tabBarItem.title = @"图标5";
//    viewController5.tabBarItem.image = [UIImage imageNamed:@"图标5"];
//
//    // 将 ViewController1 到 ViewController5 添加到 TabBarController 中
//    self.rootTabbar.viewControllers = @[viewController1, viewController2, viewController3, viewController4, viewController5];
    rootViewController *root = [[rootViewController alloc]init];
    UINavigationController * RootNavigation = [[UINavigationController alloc] initWithRootViewController:root];;
    self.window.rootViewController = RootNavigation;
    self.window.backgroundColor = [UIColor whiteColor];
    
    
}


- (void)sceneDidDisconnect:(UIScene *)scene {
    // Called as the scene is being released by the system.
    // This occurs shortly after the scene enters the background, or when its session is discarded.
    // Release any resources associated with this scene that can be re-created the next time the scene connects.
    // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
}


- (void)sceneDidBecomeActive:(UIScene *)scene {
    // Called when the scene has moved from an inactive state to an active state.
    // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
}


- (void)sceneWillResignActive:(UIScene *)scene {
    // Called when the scene will move from an active state to an inactive state.
    // This may occur due to temporary interruptions (ex. an incoming phone call).
}


- (void)sceneWillEnterForeground:(UIScene *)scene {
    // Called as the scene transitions from the background to the foreground.
    // Use this method to undo the changes made on entering the background.
}


- (void)sceneDidEnterBackground:(UIScene *)scene {
    // Called as the scene transitions from the foreground to the background.
    // Use this method to save data, release shared resources, and store enough scene-specific state information
    // to restore the scene back to its current state.
}


@end
