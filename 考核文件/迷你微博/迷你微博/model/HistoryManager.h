//
//  HistoryManger.h
//  迷你微博
//
//  Created by jimmy on 5/16/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^HistoryDataCompletionBlock)(NSArray *historyData);
@interface HistoryManager : NSObject


@property (nonatomic, strong, readwrite) NSArray *historyArray;

+ (instancetype)sharedManager;

//清空历史数据

- (void)clearHistoryData;

- (void)loadHistoryDataWithCompletion:(HistoryDataCompletionBlock)completion;


@end

NS_ASSUME_NONNULL_END
