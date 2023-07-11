//
//  ImageLoader.m
//  迷你微博
//
//  Created by jimmy on 5/11/23.
//

#define imageThreshold 200

#import "ImageLoader.h"
#import <AFNetworking/AFNetworking.h>


@interface ImageLoader()

@property (nonatomic, strong) NSMutableDictionary *imageCache;
@property (nonatomic, strong) NSMutableArray *imageThresholdArrary;

@end

@implementation ImageLoader

+ (instancetype)sharedInstance {
    static ImageLoader *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        sharedInstance.imageCache = [NSMutableDictionary dictionary];
        sharedInstance.imageThresholdArrary = [NSMutableArray array];
        
    });
    return sharedInstance;
}

//- (void)loadImageWithURL:(NSURL *)url completion:(void (^)(UIImage *image))completion {
//    // 先从本地获取图片，如果不存在再从网络请求
//    [self loadImageFromCacheWithURL:url completion:^(UIImage *cachedImage) {
//        if (cachedImage) {
//            completion(cachedImage);
//        } else {
//            NSURLSession *session = [NSURLSession sharedSession];
//            NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//                if (error) {
//                    NSLog(@"Error: %@", error.localizedDescription);
//                    return;
//                }
//
//                if (data) {
//                    UIImage *image = [UIImage imageWithData:data];
//
//                    if (image) {
//                        // 如果超过缓存阈值，删除 dictionary 中最早的图片
//                        if(self.imageCache.count >= imageThreshold){
//                            [self.imageCache removeObjectForKey: [self.imageThresholdArrary firstObject]];
//                            [self.imageThresholdArrary removeObjectAtIndex:0];
//                        }
//                        [self.imageCache setObject:image forKey:url.absoluteString];
//                        [self.imageThresholdArrary addObject:url];
//
//                        dispatch_async(dispatch_get_main_queue(), ^{
//                            completion(image);
//                        });
//
//                        [self saveImage:image withURL:url];
//                    }
//                }
//            }];
//
//            [task resume];
//        }
//    }];
//}

- (void)loadImageWithURL:(NSURL *)url completion:(void (^)(UIImage *image))completion {
    // 先从本地获取图片，如果不存在再从网络请求
    UIImage *cachedImage = [self.imageCache objectForKey:url.absoluteString];
    if (cachedImage) {
        completion(cachedImage);
        
    }else{
        
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.responseSerializer = [AFImageResponseSerializer serializer];
        
        [manager GET:url.absoluteString parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if (responseObject && [responseObject isKindOfClass:[UIImage class]]) {
                UIImage *image = responseObject;
                
                // 如果超过缓存阈值，删除 dictionary 中最早的图片
                if (self.imageCache.count >= imageThreshold) {
                    [self.imageCache removeObjectForKey: [self.imageThresholdArrary firstObject]];
                    [self.imageThresholdArrary removeObjectAtIndex:0];
                }
                
                [self.imageCache setObject:image forKey:url.absoluteString];
                [self.imageThresholdArrary addObject:url.absoluteString];
                
                completion(image);
                [self saveImage:image withURL:url];
            } else {
                NSLog(@"Not a picture");
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"Error: %@", error.localizedDescription);
        }];
    }
}




- (void)saveImage:(UIImage *)image withURL:(NSURL *)url {
    // 保存图片到本地，key 为图片的URL
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *filename = url.absoluteString;
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
        NSString *filePath = [path stringByAppendingPathComponent:filename];
        
        NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
        [imageData writeToFile:filePath atomically:YES];
    });
}


- (void)loadImageFromCacheWithURL:(NSURL *)url completion:(void (^)(UIImage *))completion {
    NSString *filename = url.absoluteString;
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filePath = [path stringByAppendingPathComponent:filename];
    // 检查 dictionary 是否有这张图片
    UIImage *cachedImage = [self.imageCache objectForKey:url.absoluteString];
    if (cachedImage) {
        completion(cachedImage);
        return;
    }
    // dictionary中不存在，就从文件夹中获取
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *imageData = [NSData dataWithContentsOfFile:filePath];
            UIImage *image = [UIImage imageWithData:imageData];
            if (image) {
                // 如果超过缓存阈值，删除 dictionary 中最早的图片
                if(self.imageCache.count >= imageThreshold){
                    [self.imageCache removeObjectForKey: [self.imageThresholdArrary firstObject]];
                    [self.imageThresholdArrary removeObjectAtIndex:0];
                }
                [self.imageThresholdArrary addObject:url];
                [self.imageCache setObject:image forKey:url.absoluteString];
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(image);
                });
            }
        });
        return;
    }
    
    completion(nil);
}

- (UIImage *)loadImageFromCacheWithURL:(NSURL *)url {
    NSString *filename = url.absoluteString;
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filePath = [path stringByAppendingPathComponent:filename];

    UIImage *cachedImage = [self.imageCache objectForKey:url.absoluteString];
    if (cachedImage) {
        return cachedImage;
    }

    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSData *imageData = [NSData dataWithContentsOfFile:filePath];
        UIImage *image = [UIImage imageWithData:imageData];
        if (image) {
            if(self.imageCache.count >= imageThreshold){
                [self.imageCache removeObjectForKey: [self.imageThresholdArrary firstObject]];
                [self.imageThresholdArrary removeObjectAtIndex:0];
            }
            [self.imageThresholdArrary addObject:url];
            [self.imageCache setObject:image forKey:url.absoluteString];
            return image;
        }
    }

    return nil;
}

@end
