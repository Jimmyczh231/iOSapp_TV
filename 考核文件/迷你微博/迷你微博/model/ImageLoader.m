//
//  ImageLoader.m
//  迷你微博
//
//  Created by jimmy on 5/11/23.
//

#import "ImageLoader.h"

@interface ImageLoader()

@property (nonatomic, strong) NSMutableDictionary *imageCache;

@end

@implementation ImageLoader

+ (instancetype)sharedInstance {
    static ImageLoader *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        sharedInstance.imageCache = [NSMutableDictionary dictionary];
    });
    return sharedInstance;
}

- (void)loadImageWithURL:(NSURL *)url completion:(void (^)(UIImage *image))completion {
    UIImage *cachedImage = [self.imageCache objectForKey:url.absoluteString];
    if (cachedImage) {
        completion(cachedImage);
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *imageData = [NSData dataWithContentsOfURL:url];
        UIImage *image = [UIImage imageWithData:imageData];
        
        if (image) {
            [self.imageCache setObject:image forKey:url.absoluteString];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(image);
            });
            
            [self saveImage:image withURL:url];
        }
    });
}

- (void)saveImage:(UIImage *)image withURL:(NSURL *)url {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *filename = [url.absoluteString lastPathComponent];
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
        NSString *filePath = [path stringByAppendingPathComponent:filename];
        
        NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
        [imageData writeToFile:filePath atomically:YES];
    });
}

- (UIImage *)loadImageFromCacheWithURL:(NSURL *)url {
    NSString *filename = [url.absoluteString lastPathComponent];
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
            [self.imageCache setObject:image forKey:url.absoluteString];
            return image;
        }
    }
    
    return nil;
}

@end
