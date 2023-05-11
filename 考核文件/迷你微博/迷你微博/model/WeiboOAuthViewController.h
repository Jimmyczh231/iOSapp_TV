//
//  WeiboOAuthViewController.h
//  迷你微博
//
//  Created by jimmy on 5/11/23.
//

#import "ViewController.h"
#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WeiboOAuthViewController : ViewController <WKNavigationDelegate>
@property (nonatomic, copy) NSString *clientID;
@property (nonatomic, copy) NSString *clientSecret;
@property (nonatomic, copy) NSString *redirectURI;
@property (nonatomic, strong) UIViewController *pushViewController;

- (instancetype)initWithCompletion:(void (^)(NSString * _Nullable accessToken, NSError * _Nullable error))completion;

- (void)authorize;
@end

NS_ASSUME_NONNULL_END
