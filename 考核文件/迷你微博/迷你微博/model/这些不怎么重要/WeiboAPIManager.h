//
//  WeiboAPIManager.h
//  迷你微博
//
//  Created by jimmy on 5/11/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface WeiboAPIManager : NSObject


@property (nonatomic, readonly) NSString *baseURL;
@property (nonatomic, readonly) NSString *statusesHomeTimelineURL;
@property (nonatomic, readonly) NSString *statusesMentionsURL;
@property (nonatomic, readonly) NSString *statusesShowURL;
@property (nonatomic, readonly) NSString *commentsCreateURL;

+ (instancetype)sharedManager;

@end




NS_ASSUME_NONNULL_END
