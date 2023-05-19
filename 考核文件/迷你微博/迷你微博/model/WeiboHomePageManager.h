//
//  WeiboHomePageManager.h
//  迷你微博
//
//  Created by jimmy on 5/12/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface WeiboHomePageManager : NSObject

@property (nonatomic, copy, readonly) NSString *accessToken;
@property (nonatomic, copy, readwrite) NSNumber *nextPageCursor; // 下一页的下标


- (instancetype)initWithAccessToken:(NSString *)accessToken;

- (void)refreshHomePageDataWithCompletion:(void(^)(BOOL success, NSArray *weiboDataArray))completion;

- (void)loadMoreHomePageDataWithCompletion:(void(^)(BOOL success, NSArray *weiboDataArray))completion;

@end


NS_ASSUME_NONNULL_END
