//
//  ImageLoader.h
//  迷你微博
//
//  Created by jimmy on 5/11/23.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN


@interface ImageLoader : NSObject

+ (instancetype)sharedInstance;

- (void)loadImageWithURL:(NSURL *)url completion:(void (^)(UIImage *image))completion;

- (UIImage *)loadImageFromCacheWithURL:(NSURL *)url;


@end

NS_ASSUME_NONNULL_END
