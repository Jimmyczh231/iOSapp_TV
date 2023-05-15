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

@interface WeiboHomePageManager ()


@property (nonatomic, strong) NSMutableArray *weiboDataArray;
@property (nonatomic, assign) BOOL isAuthorized;

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

    // 添加请求参数
    NSString *params;
    if (self.isAuthorized){
        params = [NSString stringWithFormat:@"access_token=%@&count=%d&feature=2", [AccessToken sharedInstance].accessToken, kWeiboDataCount];
        
    }else{
        params = [NSString stringWithFormat:@"count=%d&source=%@", kWeiboDataCount,Appkey];
    }
    NSString *fullUrlString = [NSString stringWithFormat:@"%@?%@", urlHead, params];
    
    url = [NSURL URLWithString:fullUrlString];
    
    // 构造网络请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    
    // 发送网络请求
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error: %@", error);
            completion(NO, nil);
            return;
        }
        
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        NSArray *statusesArray = [resultDict objectForKey:@"statuses"];
//        for (NSDictionary *statusDict in statusesArray) {
            // 解析微博数据并保存到数组中
            // 例如：NSString *text = [statusDict objectForKey:@"text"];
            // WeiboModel *weiboModel = [[WeiboModel alloc] initWithText:text];
            // [self.weiboDataArray addObject:weiboModel];
//        }
        // 更新 nextPageCursor
        self.weiboDataArray = [statusesArray mutableCopy];
        self.nextPageCursor = [NSNumber numberWithInt:2];
        completion(YES, self.weiboDataArray);
    }];
    [task resume];
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
    
    // 构造网络请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    
    // 发送网络请求
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error: %@", error);
            completion(NO, nil);
            return;
        }
        
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        NSArray *statusesArray = [resultDict objectForKey:@"statuses"];
        self.weiboDataArray = [statusesArray mutableCopy];
        self.nextPageCursor = [NSNumber numberWithInt:[self.nextPageCursor intValue]+1];
        completion(YES, self.weiboDataArray);
    }];
    [task resume];
}

@end
