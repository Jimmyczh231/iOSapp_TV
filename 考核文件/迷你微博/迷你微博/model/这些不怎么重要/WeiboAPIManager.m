//
//  WeiboAPIManager.m
//  迷你微博
//
//  Created by jimmy on 5/11/23.
//

#import "WeiboAPIManager.h"

@implementation WeiboAPIManager



+ (instancetype)sharedManager {
    static WeiboAPIManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    return _sharedManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _baseURL = @"https://api.weibo.com/2/";
        _statusesHomeTimelineURL = @"statuses/home_timeline.json";
        _statusesMentionsURL = @"statuses/mentions.json";
        _statusesShowURL = @"statuses/show.json";
        _commentsCreateURL = @"comments/create.json";
    }
    return self;
}


@end
