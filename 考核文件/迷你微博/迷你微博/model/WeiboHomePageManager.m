//
//  WeiboHomePageManager.m
//  迷你微博
//
//  Created by jimmy on 5/12/23.
//
#define kWeiboDataCount 20
#define Appkey @"2262783794"
//#define Appkey2 @"3102869047"

#define Redirect_Uri @"http://localhost/com.jimmyczh.jimmy"
#import "WeiboHomePageManager.h"
#import "AccessToken.h"
#import <AFNetworking/AFNetworking.h>

@interface WeiboHomePageManager ()

@property (nonatomic, strong) NSMutableArray *weiboDataArray; // 微博数据
@property (nonatomic, assign) BOOL isAuthorized; // 用户是否授权

@end

@implementation WeiboHomePageManager

- (instancetype)initWithAccessToken:(NSString *)accessToken
{
    self = [super init];
    if (self) {
        // 初始化属性
        self.weiboDataArray = [NSMutableArray array];
        self.nextPageCursor = [NSNumber numberWithInt:2];
        self.isAuthorized = NO; // 默认为未授权
    }
    return self;
}

- (void)refreshHomePageDataWithCompletion:(void (^)(BOOL, NSArray *))completion
{
    NSURL *url;
    self.isAuthorized = ([AccessToken sharedInstance].accessToken != nil);
    
    NSString * urlHead;
    if (self.isAuthorized) {
        // 使用授权后的 API 进行请求
        urlHead = @"https://api.weibo.com/2/statuses/home_timeline.json";
    } else {
        // 使用公共 API 进行请求
        urlHead = @"https://api.weibo.com/2/statuses/public_timeline.json";
    }
    
//    // 添加请求参数
//    NSString *params;
//    if (self.isAuthorized) {
//        params = [NSString stringWithFormat:@"access_token=%@&count=%d&feature=2", [AccessToken sharedInstance].accessToken, kWeiboDataCount];
//
//    } else {
//        params = [NSString stringWithFormat:@"count=%d&source=%@", kWeiboDataCount,Appkey];
//    }
//    NSString *fullUrlString = [NSString stringWithFormat:@"%@?%@", urlHead, params];
    
    NSDictionary *parameter;
    if(self.isAuthorized){
        parameter = @{
            @"access_token" : [AccessToken sharedInstance].accessToken,
            @"count" : @(kWeiboDataCount),
            @"feature" : @2
        };
    } else {
        parameter = @{
            @"count" : @(kWeiboDataCount),
            @"source" : Appkey
        };
    }
    
//    // 网络请求
//    url = [NSURL URLWithString:fullUrlString];
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
//    [request setHTTPMethod:@"GET"];
//
//
//    // 发送网络请求
//    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        if (error) {
//            NSLog(@"Error: %@", error.localizedDescription);
//            completion(NO, nil);
//            return;
//        }
//
//        // 保存接收到的数据
//        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
//        NSArray *statusesArray = [resultDict objectForKey:@"statuses"];
//        self.weiboDataArray = [statusesArray mutableCopy];
//
//        // 更新页数计数器
//        self.nextPageCursor = [NSNumber numberWithInt:2];
//        completion(YES, self.weiboDataArray);
//    }];
//    [task resume];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager GET:urlHead parameters:parameter headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSDictionary *resultDict = (NSDictionary *)responseObject;
            NSArray *statusesArray = [resultDict objectForKey:@"statuses"];
            self.weiboDataArray = [statusesArray mutableCopy];
            
            // 更新页数计数器
            self.nextPageCursor = [NSNumber numberWithInt:2];
            completion(YES, self.weiboDataArray);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"Error: %@", error.localizedDescription);
            completion(NO, nil);
        }];
    
    
}

- (void)loadMoreHomePageDataWithCompletion:(void (^)(BOOL, NSArray *))completion
{
    self.isAuthorized = ([AccessToken sharedInstance].accessToken != nil);
    NSURL *url;
    NSString * urlHead;
    if (self.isAuthorized) {
        // 使用授权后的 API 进行请求
        urlHead = @"https://api.weibo.com/2/statuses/home_timeline.json";
    } else {
        // 使用公共 API 进行请求
        urlHead = @"https://api.weibo.com/2/statuses/public_timeline.json";
    }

    // 添加请求参数
    NSString *params;
    if (self.isAuthorized){
        params = [NSString stringWithFormat:@"access_token=%@&count=%d&page=%@", [AccessToken sharedInstance].accessToken, kWeiboDataCount, self.nextPageCursor];
        
    }else{
        params = [NSString stringWithFormat:@"count=%d&page=%@", kWeiboDataCount, self.nextPageCursor];
    }
    NSString *fullUrlString = [NSString stringWithFormat:@"%@?%@", urlHead, params];
    url = [NSURL URLWithString:fullUrlString];
    
    NSDictionary *parameter;
    if(self.isAuthorized){
        parameter = @{
            @"access_token" : [AccessToken sharedInstance].accessToken,
            @"counnt" : @(kWeiboDataCount),
            @"page" : self.nextPageCursor
        };
    } else {
        parameter = @{
            @"count" : @(kWeiboDataCount),
            @"page" : self.nextPageCursor
        };
    }
    
//    // 构造网络请求
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
//    [request setHTTPMethod:@"GET"];
//
//    // 发送网络请求
//    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        if (error) {
//            NSLog(@"Error: %@", error.localizedDescription);
//            completion(NO, nil);
//            return;
//        }
//        // 保存接收到的数据
//        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
//        NSArray *statusesArray = [resultDict objectForKey:@"statuses"];
//        self.weiboDataArray = [statusesArray mutableCopy];
//        // 页数计数器加一
//        self.nextPageCursor = [NSNumber numberWithInt:[self.nextPageCursor intValue]+1];
//        completion(YES, self.weiboDataArray);
//    }];
//    [task resume];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager GET:urlHead parameters:parameter headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSDictionary *resultDict = (NSDictionary *)responseObject;
            NSArray *statusesArray = [resultDict objectForKey:@"statuses"];
            self.weiboDataArray = [statusesArray mutableCopy];
            
            // 页数计数器加一
            self.nextPageCursor = [NSNumber numberWithInt:[self.nextPageCursor intValue]+1];
            completion(YES, self.weiboDataArray);
        
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"Error: %@", error.localizedDescription);
            completion(NO, nil);
        }];
    
    
}

@end
