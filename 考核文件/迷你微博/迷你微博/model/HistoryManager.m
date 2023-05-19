//
//  HistoryManger.m
//  迷你微博
//
//  Created by jimmy on 5/16/23.
//

// 存储历史记录的文件名
#define kHistoryFileName @"HistoryData.plist"


#import "HistoryManager.h"

@implementation HistoryManager



+ (instancetype)sharedManager {
    static HistoryManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[HistoryManager alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        // 从本地读取历史记录数据
        NSString *filePath = [self historyFilePath];
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            self.historyArray = [NSArray arrayWithContentsOfFile:filePath];
        } else {
            self.historyArray = @[];
        }
        
        // 监听通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addHistoryDataNotificationReceived:) name:@"AddHistoryData" object:nil];
    }
    return self;
}

- (void)dealloc {

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)saveHistoryData:(NSDictionary *)data {
    // 从历史记录中删除 data，并将其放在第一位
    NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:self.historyArray];
    for (NSDictionary *existingData in mutableArray) {
        if ([[existingData objectForKey:@"id"] isEqualToNumber:[data objectForKey:@"id"]]) {
            [mutableArray removeObject:existingData];
            break;
        }
    }
    [mutableArray insertObject:data atIndex:0];
    self.historyArray = [NSArray arrayWithArray:mutableArray];
    
    // 将历史记录数据异步存入本地
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 将历史记录数据存入本地
        NSString *filePath = [self historyFilePath];
        [self.historyArray writeToFile:filePath atomically:YES];
    });
    
}

- (void)clearHistoryData {
    // 清空数组和本地存储的历史数据
    self.historyArray = @[];
    NSString *filePath = [self historyFilePath];
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
}

- (NSString *)historyFilePath {
    NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    return [documentsDirectory stringByAppendingPathComponent:kHistoryFileName];
}

// 处理信息并存入
- (void)addHistoryDataNotificationReceived:(NSNotification *)notification {
    NSDictionary *data = notification.userInfo;
    [self saveHistoryData:data];
}

- (void)loadHistoryDataWithCompletion:(HistoryDataCompletionBlock)completion {
    if (completion) {
        completion(self.historyArray);
    }
}

@end
