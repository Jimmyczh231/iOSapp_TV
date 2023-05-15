//
//  MyWeiboViewManager.h
//  迷你微博
//
//  Created by jimmy on 5/15/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MyWeiboViewManager : NSObject

- (void)refreshMyWeiboPageDataWithCompletion:(void (^)(BOOL, NSDictionary *))completion;

@end

NS_ASSUME_NONNULL_END
