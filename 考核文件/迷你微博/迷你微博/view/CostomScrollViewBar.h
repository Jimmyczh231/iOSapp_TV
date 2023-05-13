//
//  CostomScrollViewBar.h
//  迷你微博
//
//  Created by jimmy on 5/13/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CostomScrollViewBarDelegate <NSObject>

- (void)WeiboSenderPush;

@end

@interface CostomScrollViewBar : UIView

@property (nonatomic, weak) id<CostomScrollViewBarDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
