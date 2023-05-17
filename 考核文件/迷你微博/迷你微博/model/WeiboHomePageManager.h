//
//  WeiboHomePageManager.h
//  迷你微博
//
//  Created by jimmy on 5/12/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface WeiboHomePageManager : NSObject

@property (nonatomic, copy, readonly) NSString *accessToken; // 用户授权后获取的访问令牌
@property (nonatomic, assign, readonly) BOOL isAuthorized; // 用户是否已授权
@property (nonatomic, strong, readonly) NSArray *weiboDataArray; // 微博数据数组，保存 WeiboModel 对象
@property (nonatomic, copy, readwrite) NSNumber *nextPageCursor; // 下一页的游标

/**
 * 初始化方法
 * @param accessToken 用户授权后获取的访问令牌
 */
- (instancetype)initWithAccessToken:(NSString *)accessToken;

/**
 * 加载主页数据方法
 * @param completion 加载完成的回调
 */
- (void)refreshHomePageDataWithCompletion:(void(^)(BOOL success, NSArray *weiboDataArray))completion;

/**
 * 加载更多主页数据方法
 * @param completion 加载完成的回调
 */
- (void)loadMoreHomePageDataWithCompletion:(void(^)(BOOL success, NSArray *weiboDataArray))completion;

@end


NS_ASSUME_NONNULL_END
