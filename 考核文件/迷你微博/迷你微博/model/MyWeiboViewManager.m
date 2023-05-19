//
//  MyWeiboViewManager.m
//  迷你微博
//
//  Created by jimmy on 5/15/23.
//
#define kWeiboDataCount 20
#define Appkey @"2262783794"
//#define Appkey2 @"3102869047"

#define Redirect_Uri @"http://localhost/com.jimmyczh.jimmy"
#import "AccessToken.h"
#import "MyWeiboViewManager.h"


@interface MyWeiboViewManager ()


@property (nonatomic, strong) NSMutableDictionary *weiboDataDictionary;
@property (nonatomic, assign) BOOL isAuthorized;

@end

@implementation MyWeiboViewManager



- (void)refreshMyWeiboPageDataWithCompletion:(void (^)(BOOL, NSDictionary *))completion
{
    NSURL *url;
    self.isAuthorized = ([AccessToken sharedInstance].accessToken != nil);
    
    NSString * urlHead;
    if (self.isAuthorized) {
        // 使用授权后的 API 进行请求
        urlHead = @"https://api.weibo.com/2/users/show.json";
    }

    // 添加请求参数
    NSString *params;
    if (self.isAuthorized) {
        params = [NSString stringWithFormat:@"access_token=%@&uid=%@", [AccessToken sharedInstance].accessToken,[AccessToken sharedInstance].uid];
    }
    NSString *fullUrlString = [NSString stringWithFormat:@"%@?%@", urlHead, params];
    url = [NSURL URLWithString:fullUrlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    
    // 发送网络请求
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error: %@", error.localizedDescription);
            completion(NO, nil);
            return;
        }
        // 保存接收后的信息
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        self.weiboDataDictionary = [resultDict mutableCopy];

        completion(YES, self.weiboDataDictionary);
    }];
    [task resume];
}
@end
