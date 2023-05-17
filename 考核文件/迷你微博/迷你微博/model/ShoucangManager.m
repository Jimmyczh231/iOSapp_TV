//
//  ShoucangManager.m
//  迷你微博
//
//  Created by jimmy on 5/17/23.
//
#define kShoucangFileName @"ShoucangData.plist"
#import "ShoucangManager.h"

@implementation ShoucangManager





+ (instancetype)sharedManager {
    static ShoucangManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ShoucangManager alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        // 从本地读取历史记录数据
        NSString *filePath = [self shoucangFilePath];
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            self.shoucangArray = [NSArray arrayWithContentsOfFile:filePath];
        } else {
            self.shoucangArray = @[];
        }
        
        // 监听通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addShoucangDataNotificationReceived:) name:@"AddShoucangData" object:nil];
    }
    return self;
}

- (void)dealloc {

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)saveShoucangData:(NSDictionary *)data {
    NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:self.shoucangArray];
    for (NSDictionary *existingData in mutableArray) {
        if ([existingData isEqualToDictionary:data]) {
            [mutableArray removeObject:existingData];
            break;
        }
    }
    
    [mutableArray insertObject:data atIndex:0];
    self.shoucangArray = [NSArray arrayWithArray:mutableArray];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 将历史记录数据存入本地
        NSString *filePath = [self shoucangFilePath];
        [self.shoucangArray writeToFile:filePath atomically:YES];

        });
    
//    // 将历史记录数据异步存入本地
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSString *filePath = [self historyFilePath];
//        [self.historyArray writeToFile:filePath atomically:YES];
//    });
}

- (void)clearShoucangData {
    // 清空数组和本地存储的历史数据
    self.shoucangArray = @[];
    NSString *filePath = [self shoucangFilePath];
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
}

- (NSString *)shoucangFilePath {
    NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    return [documentsDirectory stringByAppendingPathComponent:kShoucangFileName];
}

// 处理信息并存入
- (void)addShoucangDataNotificationReceived:(NSNotification *)notification {
    NSDictionary *data = notification.userInfo;
    [self saveShoucangData:data];
}

- (void)loadShoucangDataWithCompletion:(ShoucangDataCompletionBlock)completion {
    if (completion) {
        completion(self.shoucangArray);
    }
}

@end



