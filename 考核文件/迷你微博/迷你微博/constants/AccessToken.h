//
//  AccessToken.h
//  迷你微博
//
//  Created by jimmy on 5/11/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AccessToken : NSObject

@property (nonatomic, copy) NSString *accessToken;

+ (instancetype)sharedInstance;

@end


NS_ASSUME_NONNULL_END
