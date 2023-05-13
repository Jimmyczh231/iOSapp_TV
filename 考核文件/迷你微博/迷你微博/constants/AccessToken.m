//
//  AccessToken.m
//  迷你微博
//
//  Created by jimmy on 5/11/23.
//


#import "AccessToken.h"

@implementation AccessToken

+ (instancetype)sharedInstance {
    static AccessToken *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if(instance == nil){
            instance = [[AccessToken alloc] init];
        }
    });
    return instance;
}

@end

