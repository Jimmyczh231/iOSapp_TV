//
//  WeiboOAuthHelper.h
//  迷你微博
//
//  Created by jimmy on 5/11/23.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import "testviewcontroller.h"
NS_ASSUME_NONNULL_BEGIN

@interface WeiboOAuthHelper : NSObject <WKNavigationDelegate>

@property (nonatomic, copy) NSString *clientID;
@property (nonatomic, copy) NSString *clientSecret;
@property (nonatomic, copy) NSString *redirectURI;


- (instancetype)initWithCompletion:(void (^)(NSString * _Nullable accessToken, NSError * _Nullable error))completion;

- (void)authorize;

@end

NS_ASSUME_NONNULL_END
