//
//  WeiboDetailViewManager.m
//  迷你微博
//
//  Created by jimmy on 5/17/23.
//

#import "WeiboDetailViewManager.h"
#import "AccessToken.h"

@interface WeiboDetailViewManager ()


@property (nonatomic, strong) NSMutableDictionary *weiboDataDictionary;
@property (nonatomic, assign) BOOL isAuthorized;

@end


@implementation WeiboDetailViewManager



- (void)loadWeiboDetailPageDataWith:(NSString*)weiboId andWithCompletion:(void (^)(BOOL, NSDictionary *))completion{
    
    NSString * urlHead;
    NSURL *url;
    self.isAuthorized = ([AccessToken sharedInstance].accessToken != nil);
    
    if (self.isAuthorized) {
        urlHead = @"https://api.weibo.com/2/statuses/show.json";
    } 

    // 添加请求参数
    NSString *params;
    if (self.isAuthorized){
        params = [NSString stringWithFormat:@"access_token=%@&id=%@", [AccessToken sharedInstance].accessToken, weiboId];
        
    }
    NSString *fullUrlString = [NSString stringWithFormat:@"%@?%@", urlHead, params];
    
    
    // 构造网络请求
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
        
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];

        completion(YES, resultDict);
    }];
    [task resume];
}



@end
