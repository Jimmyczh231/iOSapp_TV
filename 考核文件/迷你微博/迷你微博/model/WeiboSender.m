//
//  WeiboSender.m
//  迷你微博
//
//  Created by jimmy on 5/13/23.
//

#import "WeiboSender.h"
#import "AccessToken.h"
#include <ifaddrs.h>

#include <arpa/inet.h>

@implementation WeiboSender

+ (instancetype)sharedInstance {
    static WeiboSender *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}


- (void)sendWeiboWithText:(NSString *)text {

    // URL
    NSString *url = @"https://api.weibo.com/2/statuses/update.json";
    NSString *access_token = [AccessToken sharedInstance].accessToken;
    NSCharacterSet *allowedCharacterSet = [NSCharacterSet URLQueryAllowedCharacterSet];
    NSString *status = [text stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
    NSString *params = [NSString stringWithFormat:@"access_token=%@&status=%@&rip=%@", access_token, status, [self getIPAddress]];
    NSString *fullSendUrlString = [NSString stringWithFormat:@"%@?%@",url,params];
    NSURL *fullSendUrl = [NSURL URLWithString:fullSendUrlString];
    
    // 初始化网络请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:fullSendUrl];
    request.HTTPMethod = @"POST";
     
    // 发送微博请求
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            // 请求成功，解析返回结果
            NSError *jsonError = nil;
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
            if (jsonError) {
                NSLog(@"Error: %@", [jsonError localizedDescription]);
            } else {
                NSLog(@"Weibo sent success, result: %@", result);
            }
        } else {
            // 请求失败，输出错误信息
            NSLog(@"Error: %@", [error localizedDescription]);
        }
    }];
    [task resume];
}


// 这个不是我写的，但是发送微博需要网络ip
- (NSString *)getIPAddress {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;

    // 获取本地所有网络接口列表
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // 循环处理每个网络接口
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if (temp_addr->ifa_addr->sa_family == AF_INET) {
                // 如果是 IPv4 地址，则获取它
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // 在 Wi-Fi 网络下，en0 端口通常是本地 IPv4 地址
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }

    // 释放接口列表
    freeifaddrs(interfaces);

    return address;
}

@end
