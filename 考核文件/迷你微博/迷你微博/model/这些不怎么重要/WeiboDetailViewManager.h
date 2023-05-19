//
//  WeiboDetailViewManager.h
//  迷你微博
//
//  Created by jimmy on 5/17/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WeiboDetailViewManager : NSObject

- (void)loadWeiboDetailPageDataWith:(NSString*)weiboId andWithCompletion:(void (^)(BOOL, NSDictionary *))completion;


@end

NS_ASSUME_NONNULL_END
