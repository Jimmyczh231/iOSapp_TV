//
//  ShoucangManager.h
//  迷你微博
//
//  Created by jimmy on 5/17/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^ShoucangDataCompletionBlock)(NSArray *shoucangData);

@interface ShoucangManager : NSObject

@property (nonatomic, strong, readwrite) NSArray *shoucangArray;

+ (instancetype)sharedManager;

- (void)clearShoucangData;

- (void)loadShoucangDataWithCompletion:(ShoucangDataCompletionBlock)completion;


@end

NS_ASSUME_NONNULL_END
